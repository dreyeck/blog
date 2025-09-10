(ns importer.posts
  (:require [clojure.java.io :as io]
            [clojure.core.match :refer [match]]
            [slugger.core :refer [->slug]]
            [hickory.core :as hickory]
            [clojure.string :as str]
            [importer.utils :as utils]
            [importer.media :as media]))

(declare els->md
         el->md)

(defn get-taxonomy [domain item-xml]
  (->> item-xml
       :content
       (filter (fn [el] (and (= (:tag el)
                                :category)
                             (= (->> el :attrs :domain)
                                domain))))
       (map (fn [el]
              {:name (->> el :content first)
               :slug (:nicename (:attrs el))}))))

(defn medium-url->medium [media medium-url]
  (utils/vector-find #(= (:url %) medium-url)
                     media))

;; Conversion

(defn fix-url [media url]
  (let [normalized-url (utils/normalize url)
        blog-match (re-matches #".*://blog[.]agj[.]cl(.*)" normalized-url)
        agj-cl-match (re-matches #".*:(//.*[.]agj[.]cl.*)" normalized-url)
        wp-content-match (re-matches #".*://blog[.]agj[.]cl/wp-content/uploads/(\d+)/(\d+)/(.*)" normalized-url)]
    (or (if wp-content-match
          (let [medium (medium-url->medium media normalized-url)]
            (str "/files/"
                 (:year medium) "/"
                 (:month medium) "-"
                 (:related-post medium) "/"
                 (:filename medium)))
          nil)
        (let [blog-url (get blog-match 1)]
          (if blog-url
            (str/replace blog-url #"#more-\d+" "#language")
            nil))
        (get agj-cl-match 1)
        normalized-url)))

(defn post-xml->post [post-xml]
  (let [title (utils/get-tag-text :title post-xml)]
    {:title title
     :id (utils/get-tag-text :wp:post_id post-xml)
     :slug (utils/normalize
            (or (utils/get-tag-text :wp:post_name post-xml)
                (->slug title)))
     :date (utils/parse-date (utils/get-tag-text :wp:post_date post-xml))
     :date-gmt (utils/get-tag-text :wp:post_date_gmt post-xml)
     :categories (get-taxonomy "category" post-xml)
     :tags (get-taxonomy "post_tag" post-xml)
     :parent (utils/get-tag-text :wp:post_parent post-xml)
     :post-type (utils/get-tag-text :wp:post_type post-xml)
     :status (utils/get-tag-text :wp:status post-xml)
     :content (or (utils/get-tag-text :content:encoded post-xml)
                  "\n")
     :description (utils/get-tag-text :description post-xml)
     :excerpt (utils/get-tag-text :excerpt:encoded post-xml)}))

;; Markdown generation

(defn surround->md [media before after el]
  (str before
       (->> el :content (els->md media))
       after))

(defn h*-tag? [tag]
  (if (and tag
           (re-matches #"(?i)^h\d$" (name tag)))
    true
    false))

(defn em->md [media el]
  (surround->md media "_" "_" el))

(defn strong->md [media el]
  (surround->md media "**" "**" el))

(defn img->md [media el]
  (let [alt (->> el :attrs :alt)
        title (->> el :attrs :title)]
    (str "!["
         (if (or (not alt) (= alt ""))
           "image"
           alt)
         "]("
         (->> el :attrs :src (fix-url media))
         (if title
           (str " \"" title "\"")
           "")
         ")")))

(defn a->md [media el]
  (str "["
       (->> el :content (els->md media))
       "]("
       (->> el :attrs :href (fix-url media))
       ")"))

(defn h*->md [media el]
  (let [n (match [(:tag el)]
            [:h1] 1
            [:h2] 2
            [:h3] 3
            [:h4] 4
            [:h5] 5)]
    (str "\n"
         (apply str (repeat n "#"))
         " "
         (->> el :content first (els->md media))
         "\n")))

(defn div->md [media el]
  (if (= (->> el :attrs :class)
         "language")
    (str "\n"
         "<language-break />\n\n"
         (->> el :content (els->md media)))
    (->> el :content (els->md media))))

(defn span->md [media el]
  (cond
    (->> el :attrs :style (= "font-style: italic;")) (em->md media el)
    (->> el :attrs :class (= "postbody")) (->> el :content (els->md media))
    (->> el :attrs :class (= "s1")) (->> el :content (els->md media))
    :else "???"))

(defn blockquote->md [media el]
  (let [parsed-content (->> el :content (els->md media))]
    (str "\n"
         (->> parsed-content
              str/split-lines
              (map #(str "> " %))
              (str/join "\n"))
         "\n")))

(defn ol->md [media el]
  (->> el
       :content
       (reduce (fn [result-count el]
                 (let [result (first result-count)
                       count (second result-count)]
                   (if (= (:tag el) :li)
                     [(conj result
                            (str (inc count) ". "
                                 (->> el :content (#(els->md media %)))))
                      (inc count)]
                     [(conj result (el->md media el))
                      count])))
               [[] 0])
       first
       (apply str)))

(defn ul->md [media el]
  (->> el
       :content
       (map (fn [el]
              (if (= (:tag el)
                     :li)
                (str "- "
                     (->> el :content (#(els->md media %))))
                (el->md media el))))
       (apply str)))

(defn video-el->url [el]
  (match [(:tag el)]
    [:iframe] (->> el :attrs :src)
    [:object] (some->> el
                       (utils/get-children :param)
                       (utils/vector-find #(let [name (->> % :attrs :name)]
                                             (or (= name "src")
                                                 (= name "movie"))))
                       :attrs
                       :value)
    :else nil))

(defn vimeo-el? [el]
  (boolean
   (->> el
        video-el->url
        (re-matches #".*vimeo.*"))))

(defn youtube-el? [el]
  (boolean
   (->> el
        video-el->url
        (re-matches #".*youtube.*"))))

(defn vimeo-el->video [el]
  (let [id (->> el
                video-el->url
                (re-matches #".*(clip_id=|video\/)(\d+).*")
                (#(nth % 2)))]
    {:service "vimeo"
     :id id
     :width (->> el :attrs :width)
     :height (->> el :attrs :height)}))

(defn youtube-el->video [el]
  (let [id (->> el
                video-el->url
                (re-matches #".*(embed\/)([^?]+).*")
                (#(nth % 2)))]
    {:service "youtube"
     :id id
     :width (->> el :attrs :width)
     :height (->> el :attrs :height)}))

(defn el->video [el]
  (cond
    (vimeo-el? el) (vimeo-el->video el)
    (youtube-el? el) (youtube-el->video el)
    :else nil))

(defn video->md [video]
  (str "<video-embed "
       "service=\"" (:service video) "\" "
       "id=\"" (:id video) "\" "
       "width=\"" (:width video) "\" "
       "height=\"" (:height video) "\" "
       "/>"))

(defn el->md [media el]
  (match [(:tag el) (:type el)]
    [:em _] (em->md media el)
    [:strong _] (strong->md media el)
    [:a _] (a->md media el)
    [:img _] (img->md media el)
    [:ul _]  (ul->md media el)
    [:ol _] (ol->md media el)
    [:blockquote _] (blockquote->md media el)
    [:del _] (surround->md media "~~" "~~" el)
    [:div _] (div->md media el)
    [:span _] (span->md media el)
    [:pre _] (surround->md media "```\n" "\n```" el)
    [_ :comment] (surround->md media "<!-- " " -->" el)
    [nil nil] el
    :else (cond
            (h*-tag? (:tag el)) (h*->md media el)
            (el->video el) (video->md (el->video el))
            :else "???")))

(defn els->md [media els]
  (->> els
       (map #(el->md media %))
       (apply str)))

(defn post->md [media post]
  (->> (:content post)
       hickory/parse-fragment
       (map hickory/as-hickory)
       (els->md media)
       str/trim
       (#(str/replace % #"\n\n\n+" "\n\n"))))

;; Final processing

(defn post->string [media post]
  (let [frontmatter-data {:id (Integer/parseInt (:id post))
                          :title (:title post)
                          :day-of-month (->> post :date :date)
                          :date (->> post :date-gmt)
                          :categories (->> post :categories (map :slug))
                          :tags (->> post :tags (map :slug))
                          :language "eng"}]
    (str "---\n"
         (utils/data->yaml frontmatter-data)
         "---\n\n"
         (post->md media post)
         "\n")))

(defn post->path [post]
  (let [status (:status post)]
    (str (if (= status "draft")
           "drafts/"
           (str (->> post :date :year) "/"
                (->> post :date :month (utils/leftpad \0 2)) "-"))
         (:slug post)
         (if (= status "private")
           "-HIDDEN"
           "")
         ".md")))

(defn output-post [media post]
  (let [filename (str "../data/posts/" (post->path post))]
    (io/make-parents filename)
    (println (str "Output: " filename))
    (spit filename (post->string media post))))

;; Main

(defn output-posts [wordpress-xml]
  (let [posts-xml (->> wordpress-xml
                       (filter (fn [item-xml]
                                 (and (= (:tag item-xml) :item)
                                      (= (utils/get-tag-text :wp:post_type item-xml)
                                         "post")))))
        posts (map post-xml->post posts-xml)
        media (media/wordpress-xml->media wordpress-xml)]
    (doseq [post posts]
      (output-post media post))))
