(ns importer.media
  (:require [clojure.java.io :as io]
            [importer.utils :as utils]
            [clojure.pprint :refer [pprint]]))

(defn attachment-xml->medium [attachment-xml]
  (let [url (->> attachment-xml (utils/get-tag-text :wp:attachment_url) utils/normalize)
        url-matches (re-matches #".*wp-content/uploads/\d+/\d+/(.*)" url)
        link (->> attachment-xml (utils/get-tag-text :link) utils/normalize)
        link-matches (re-matches #".*/(\d+)/(\d+)/([^/]+)/.*" link)]
    {:url url
     :year (nth link-matches 1)
     :month (nth link-matches 2)
     :filename (nth url-matches 1)
     :related-post (nth link-matches 3)}))

(defn wordpress-xml->media [wordpress-xml]
  (->> wordpress-xml
       (filter #(and (= (:tag %)
                        :item)
                     (= (utils/get-tag-text :wp:post_type %)
                        "attachment")))
       (map attachment-xml->medium)))

(defn output-single-medium [medium do-live]
  (let [output-filename (str "../../files/"
                             (:year medium) "/"
                             (:month medium) "-"
                             (:related-post medium) "/"
                             (:filename medium))]
    (println (str "Output: " output-filename))
    (if do-live
      (do (io/make-parents output-filename)
          (with-open [in (io/input-stream (:url medium))
                      out (io/output-stream output-filename)]
            (io/copy in out)))
      (do (pprint medium)
          (println "")))))

;; Main

(defn output-media [wordpress-xml do-live]
  (let [media (wordpress-xml->media wordpress-xml)]
    (doseq [medium media]
      (output-single-medium medium do-live))))

