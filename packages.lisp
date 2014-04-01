(in-package #:common-lisp-user)

(defpackage #:zipcode-distance-api
  (:use #:common-lisp)
  (:export #:zipcode-ok-p
           #:zipcodes-for-city
           #:zipcode-info
           #:nearby-zipcodes
           #:distance-between))

