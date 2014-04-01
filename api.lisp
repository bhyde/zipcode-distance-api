(in-package #:zipcode-distance-api)

(defun zipcode-ok-p (zipcode)
  (and (stringp zipcode)
       (let ((len (length zipcode)))
          (or (= 5 len)
              (= 10 len))
          (and
           (loop for i below 5 always (digit-char-p (char zipcode i)))
           (or (= 5 len)
               (and 
                (loop for i from 6 below 10 always (digit-char-p (char zipcode i)))
                (char= #\- (char zipcode 5))))))))

;; (zipcode-ok-p "02476") --> t
;; (zipcode-ok-p "o2476") --> nil
;; (zipcode-ok-p 2476) --> nil
;; (zipcode-ok-p "02476-0000") --> T
;; (zipcode-ok-p "02476-000") --> nil

(defparameter *url-root* nil)

(defun get-url-root ()
  (or *url-root*
      (setf *url-root*
            (format nil
                 "https://zipcodedistanceapi.redline13.com/rest/~A"
                 (or (get :zipcodedistanceapi.redline13.com :token)
                     (error "Must set (get :zipcodedistanceapi.redline13.com :token)"))))))

(defun build-url (what &rest args)
  (format nil "~A/~A.json~{/~A~}" (get-url-root) what
          (mapcar #'(lambda (x) 
                      (if (stringp x)
                          (drakma:url-encode x :latin1)
                          x))
                  args)))

(defun api-call (&rest details)
  (cl-json:decode-json-from-string
      (coerce
       (loop
          with raw-result-bytes 
            = (drakma:http-request (apply #'build-url details))
          for byte across raw-result-bytes
          collect (code-char byte)) 
       'string)))

  
;;; You must arrange for (get :zipcodedistanceapi.redline13.com :token) to be
;;; set to your api key

(defun zipcodes-for-city (city-name state-name)
  (cdar (api-call "city-zips" city-name state-name)))

;; (zipcodes-for-city "boston" "ma") -->
;; ("02108" "02109" "02110" "02111" "02112" "02113" "02114" "02115" "02116"
;;  "02117" "02118" "02123" "02127" "02128" "02133" "02163" "02196" "02199" 
;;  "02201" "02203" "02204" "02205" "02206" "02207" "02210" "02211" "02212" 
;;  "02215" "02216" "02217" "02222" "02241" "02266" "02283" "02284" "02293" 
;;  "02295" "02297" "02298")

(defun zipcode-info (zipcode &optional (units :degrees))
  (assert (zipcode-ok-p zipcode))
  (assert (member units '(:degrees :radians)))
  (api-call "info" zipcode units))


;; (zipcode-info "02476") --> 
;; ((:zip--code . "02476") (:lat . 42.409992) (:lng . -71.160212)
;;  (:city . "Arlington") (:state . "MA")
;;  (:timezone (:timezone--identifier . "America/New_York")
;;   (:timezone--abbr . "EDT") (:utc--offset--sec . -14400) (:is--dst . "T")))

(defun nearby-zipcodes (zipcode distance &optional (units :mile))
  (assert (zipcode-ok-p zipcode))
  (assert (numberp distance))
  (assert (member units '(:mile :km)))
  (api-call "radius" zipcode distance units))

;; (nearby-zipcodes "02476" 2 :mile) -->
;; ((:zip--codes ((:zip--code . "02478") (:distance . 1.711))
;;   ((:zip--code . "02479") (:distance . 1.469))
;;   ((:zip--code . "02475") (:distance . 1.009))
;;   ((:zip--code . "02474") (:distance . 0.011))
;;   ((:zip--code . "02476") (:distance . 0.011))
;;   ((:zip--code . "02156") (:distance . 1.689))))

(defun distance-between (zipcode-a zipcode-b &optional (units :mile))
  (assert (member units '(:mile :km)))
  (assert (zipcode-ok-p zipcode-a))
  (assert (zipcode-ok-p zipcode-b))
  (cdar
   (api-call "distance" zipcode-a zipcode-b units)))

;; (distance-between "02478" "02476") --> 1.719
