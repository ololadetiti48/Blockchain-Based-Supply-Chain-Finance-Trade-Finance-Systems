;; Letter of Credit Contract
;; Manages letters of credit for trade finance

(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_INVALID_LC (err u201))
(define-constant ERR_LC_EXPIRED (err u202))
(define-constant ERR_INSUFFICIENT_FUNDS (err u203))
(define-constant ERR_INVALID_STATUS (err u204))
(define-constant ERR_DOCUMENTS_NOT_COMPLIANT (err u205))
(define-constant ERR_MANAGER_NOT_VERIFIED (err u206))

;; LC Status constants
(define-constant STATUS_DRAFT u0)
(define-constant STATUS_ISSUED u1)
(define-constant STATUS_CONFIRMED u2)
(define-constant STATUS_DOCUMENTS_PRESENTED u3)
(define-constant STATUS_PAYMENT_MADE u4)
(define-constant STATUS_CANCELLED u5)

;; Manager verification within this contract
(define-map verified-managers principal bool)

;; Letter of Credit data structure
(define-map letters-of-credit uint {
    issuing-bank: principal,
    beneficiary: principal,
    applicant: principal,
    amount: uint,
    currency: (string-ascii 3),
    expiry-date: uint,
    status: uint,
    created-at: uint,
    manager: principal
})

;; LC counter
(define-data-var lc-counter uint u0)

;; Document submissions
(define-map lc-documents uint (string-ascii 500))

;; Verify manager for this contract
(define-public (verify-lc-manager (manager principal))
    (begin
        (map-set verified-managers manager true)
        (ok true)
    )
)

;; Check if manager is verified
(define-read-only (is-lc-manager-verified (manager principal))
    (default-to false (map-get? verified-managers manager))
)

;; Create a new letter of credit
(define-public (create-letter-of-credit
    (beneficiary principal)
    (applicant principal)
    (amount uint)
    (currency (string-ascii 3))
    (expiry-date uint)
    (manager principal))
    (let ((lc-id (+ (var-get lc-counter) u1)))
        (asserts! (is-lc-manager-verified manager) ERR_MANAGER_NOT_VERIFIED)
        (asserts! (> expiry-date block-height) ERR_LC_EXPIRED)
        (asserts! (> amount u0) ERR_INSUFFICIENT_FUNDS)

        (map-set letters-of-credit lc-id {
            issuing-bank: tx-sender,
            beneficiary: beneficiary,
            applicant: applicant,
            amount: amount,
            currency: currency,
            expiry-date: expiry-date,
            status: STATUS_DRAFT,
            created-at: block-height,
            manager: manager
        })

        (var-set lc-counter lc-id)
        (ok lc-id)
    )
)

;; Issue the letter of credit
(define-public (issue-letter-of-credit (lc-id uint))
    (let ((lc (unwrap! (map-get? letters-of-credit lc-id) ERR_INVALID_LC)))
        (asserts! (is-eq tx-sender (get issuing-bank lc)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status lc) STATUS_DRAFT) ERR_INVALID_STATUS)
        (asserts! (> (get expiry-date lc) block-height) ERR_LC_EXPIRED)

        (map-set letters-of-credit lc-id (merge lc {status: STATUS_ISSUED}))
        (ok true)
    )
)

;; Confirm the letter of credit
(define-public (confirm-letter-of-credit (lc-id uint))
    (let ((lc (unwrap! (map-get? letters-of-credit lc-id) ERR_INVALID_LC)))
        (asserts! (is-eq (get status lc) STATUS_ISSUED) ERR_INVALID_STATUS)
        (asserts! (> (get expiry-date lc) block-height) ERR_LC_EXPIRED)

        (map-set letters-of-credit lc-id (merge lc {status: STATUS_CONFIRMED}))
        (ok true)
    )
)

;; Present documents for payment
(define-public (present-documents (lc-id uint) (documents (string-ascii 500)))
    (let ((lc (unwrap! (map-get? letters-of-credit lc-id) ERR_INVALID_LC)))
        (asserts! (is-eq tx-sender (get beneficiary lc)) ERR_UNAUTHORIZED)
        (asserts! (or (is-eq (get status lc) STATUS_ISSUED) (is-eq (get status lc) STATUS_CONFIRMED)) ERR_INVALID_STATUS)
        (asserts! (> (get expiry-date lc) block-height) ERR_LC_EXPIRED)

        (map-set lc-documents lc-id documents)
        (map-set letters-of-credit lc-id (merge lc {status: STATUS_DOCUMENTS_PRESENTED}))
        (ok true)
    )
)

;; Process payment (after document verification)
(define-public (process-payment (lc-id uint) (documents-compliant bool))
    (let ((lc (unwrap! (map-get? letters-of-credit lc-id) ERR_INVALID_LC)))
        (asserts! (is-eq tx-sender (get issuing-bank lc)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status lc) STATUS_DOCUMENTS_PRESENTED) ERR_INVALID_STATUS)
        (asserts! documents-compliant ERR_DOCUMENTS_NOT_COMPLIANT)

        (map-set letters-of-credit lc-id (merge lc {status: STATUS_PAYMENT_MADE}))
        (ok (get amount lc))
    )
)

;; Cancel letter of credit
(define-public (cancel-letter-of-credit (lc-id uint))
    (let ((lc (unwrap! (map-get? letters-of-credit lc-id) ERR_INVALID_LC)))
        (asserts! (or (is-eq tx-sender (get issuing-bank lc)) (is-eq tx-sender (get applicant lc))) ERR_UNAUTHORIZED)
        (asserts! (not (is-eq (get status lc) STATUS_PAYMENT_MADE)) ERR_INVALID_STATUS)

        (map-set letters-of-credit lc-id (merge lc {status: STATUS_CANCELLED}))
        (ok true)
    )
)

;; Get letter of credit details
(define-read-only (get-letter-of-credit (lc-id uint))
    (map-get? letters-of-credit lc-id)
)

;; Get LC documents
(define-read-only (get-lc-documents (lc-id uint))
    (map-get? lc-documents lc-id)
)

;; Get current LC counter
(define-read-only (get-lc-counter)
    (var-get lc-counter)
)
