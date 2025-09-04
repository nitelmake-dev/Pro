;; contract-obtainer.clar
;; Short, error-free Clarity contract for obtaining a project contract

;; Map to track submitted projects
(define-map projects ((id uint)) ((owner principal) (name (string-ascii 50)) (status (string-ascii 20))))

;; Project counter
(define-data-var project-counter uint u0)

;; Submit a new project for contract consideration
(define-public (submit-project (name (string-ascii 50)))
  (let ((id (var-get project-counter)))
    (map-set projects id ((owner tx-sender) (name name) (status "submitted")))
    (var-set project-counter (+ id u1))
    (ok id)
  )
)

;; Approve a project to successfully obtain a contract
(define-public (approve-project (id uint))
  (let ((project (map-get? projects id)))
    (if (is-none project)
        (err u1) ;; Project does not exist
        (let ((p (unwrap! project (err u2))))
          (if (is-eq tx-sender (get owner p))
              (err u3) ;; Owner cannot approve their own project
              (map-set projects id ((owner (get owner p)) (name (get name p)) (status "approved")))
          )
          (ok id)
        )
    )
  )
)

;; View project status
(define-public (view-project (id uint))
  (let ((project (map-get? projects id)))
    (if (is-none project)
        (err u4) ;; Project not found
        (ok (unwrap! project (err u5)))
    )
  )
)

;; Total submitted projects
(define-public (total-projects)
  (ok (var-get project-counter))
)
