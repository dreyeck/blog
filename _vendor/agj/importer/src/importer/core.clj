(ns importer.core
  (:gen-class)
  (:require [clojure.xml :as xml]
            [clojure.java.io :as io]
            [clojure.string :as str]
            [clojure.core.match :refer [match]]
            [importer.utils :as utils]
            [importer.posts :as posts]
            [importer.taxonomy :as taxonomy]
            [importer.media :as media]
            [clojure.pprint :refer [pprint]]))

;; Data

(def wordpress-xml-root (-> "wordpress-data.xml"
                            io/resource
                            io/file
                            xml/parse))

(def wordpress-xml (->> wordpress-xml-root
                        :content
                        first
                        :content))

;; Main

(defn -main
  "Generate blog data from Wordpress XML export file."
  [& args]

  (let [command (first args)]
    (match [command]
      ["posts"] (posts/output-posts wordpress-xml)
      ["taxonomy"] (taxonomy/output-taxonomy wordpress-xml)
      ["media"] (media/output-media wordpress-xml
                                    (= (second args)
                                       "live"))
      :else (do
              (println "Run with one of the following commands to generate the corresponding blog data:")
              (println "    posts, taxonomy, media [live]")))))

(comment
  (->> wordpress-xml
       (filter #(and (= (:tag %) :item)
                     (= (utils/get-tag-text :wp:post_type %) "attachment")))
       (map (fn [attachment-xml]
              (let [url (utils/get-tag-text :wp:attachment_url attachment-xml)
                    matches (re-matches #".*wp-content/uploads/(\d+)/(\d+)/(.*)" url)
                    link (utils/get-tag-text :link attachment-xml)]
                {:url url
                 :year (nth matches 1)
                 :month (nth matches 2)
                 :filename (nth matches 3)
                 :related-post (nth (re-matches #".*\d+/\d+/([^/]+)/.*" link)
                                    1)})))
       (drop 5)
       (take 3)
       (#(doseq [att %]
           (println att)
           (let [output-filename (str "../../files/"
                                      (:year att) "/"
                                      (:month att) "/"
                                      (:related-post att) "/"
                                      (:filename att))]
             (io/make-parents output-filename)
             (with-open [in (io/input-stream (:url att))
                         out (io/output-stream output-filename)]
               (io/copy in out)))))
       ;
       )

  (->> ["http://blog.agj.cl/2009/01/campodecolor-got-me-out-of-college/#more-118"
        "http://www.agj.cl/files/games/campodecolor_memoria.pdf"
        "http://blog.agj.cl/wp-content/uploads/2009/04/heartlogo1.png"
        "http://piclog.agj.cl/?picture=89"
        "http://blog.agj.cl/wp-content/uploads/2008/12/01-Traffic.mp3"
        "http://blog.agj.cl/wp-content/uploads/2020/10/japoñol-profile.png"]
       (map utils/normalize)
       (map (fn [url]
              (posts/medium-url->medium (media/wordpress-xml->media wordpress-xml)
                                        url)))
        ;; (str/join "\n")
       pprint)

  ;;
  )
