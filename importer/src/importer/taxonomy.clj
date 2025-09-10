(ns importer.taxonomy
  (:require [clojure.java.io :as io]
            [importer.utils :as utils]))

(defn category-xml->category [category-xml]
  (let [base {:name (utils/get-tag-text :wp:cat_name category-xml)
              :slug (utils/get-tag-text :wp:category_nicename category-xml)}
        parent (utils/get-tag-text :wp:category_parent category-xml)
        description (utils/get-tag-text :wp:category_description category-xml)]
    (merge base
           (if parent {:parent parent} {})
           (if description {:description description} {}))))

(defn tag-xml->tag [tag-xml]
  {:name (utils/get-tag-text :wp:tag_name tag-xml)
   :slug (utils/get-tag-text :wp:tag_slug tag-xml)})

(defn output-single-taxonomy [filename items]
  (let [filename (str "../data/" filename ".yaml")]
    (io/make-parents filename)
    (println (str "Output: " filename))
    (spit filename
          (str "---\n"
               (utils/data->yaml items)))))

;; Main

(defn output-taxonomy [wordpress-xml]
  (let [categories-xml (->> wordpress-xml
                            (filter #(= (:tag %) :wp:category)))
        categories (map category-xml->category categories-xml)
        tags-xml (->> wordpress-xml
                      (filter #(= (:tag %) :wp:tag)))
        tags (map tag-xml->tag tags-xml)]
    (output-single-taxonomy "categories" categories)
    (output-single-taxonomy "tags" tags)))
