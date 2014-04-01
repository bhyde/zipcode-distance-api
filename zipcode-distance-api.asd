;-*- mode:common-lisp -*-

(defsystem "zipcode-distance-api"
  :depends-on ("drakma" "cl-json")
  :components ((:file "packages")
               (:file "api")))

