(ns importer.utils
  (:import (java.text Normalizer
                      Normalizer$Form))
  (:require [java-time.api :as jt]
            [clj-yaml.core :as yaml]))

;; General

(defn leftpad [char length target]
  (cond
    (number? target) (leftpad char length (str target))
    (string? target) (apply str (concat (take (- length (count target))
                                              (repeat char))
                                        target))))

(defn parse-date [date-str]
  (let [date (jt/local-date-time "yyyy-MM-dd HH:mm:ss"
                                 date-str)
        get #(-> %
                 (jt/format date)
                 Integer/parseInt)]
    {:year (get "yyyy")
     :month (get "MM")
     :date (get "dd")
     :hour (get "HH")
     :minutes (get "mm")}))

(defn data->yaml [data]
  (yaml/generate-string
   data
   :dumper-options {:flow-style :block}))

(defn normalize [text]
  (Normalizer/normalize text Normalizer$Form/NFC))

;; Data traversal

(defn vector-find [pred arr]
  (->> arr
       (filter pred)
       first))

(defn get-children [tag el]
  (->> el
       :content
       (filter #(= (:tag %) tag))))

(defn get-tag-text [tag item-xml]
  (->> item-xml
       (get-children tag)
       first
       :content
       first))
