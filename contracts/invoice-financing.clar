;; Invoice Financing Contract
;; Manages invoice financing for supply chain finance

(define-constant ERR_UNAUTHORIZED (err u300))
(define-constant ERR_INVALID_INVOICE (err u301))
(define-constant ERR_INSUFFICIENT_FUNDS (err u302))
(define-constant ERR_INVALID_STATUS (err u303))
(define-constant ERR_INVOICE_EXPIRED (err u304))
(define-constant ERR_INVALID_DISCOUNT_RATE (err u305))
(define-constant ERR_MANAGER_NOT_VERIFIED (err u306))

;; Invoice status constants
(define-constant STATUS_PENDING u0)
(define-constant STATUS_APPROVED u1)
(define-constant STATUS_FUNDED u2)
(define-constant STATUS_REPAID u3)
(define-constant STATUS_DEFAULTED u4)

;; Manager verification within this contract
(define-map verified-managers principal bool)

;; Invoice financing data structure
(define-map invoice-financing uint {
    supplier: principal,
    buyer: principal,
    financier: principal,
    invoice-amount: uint,
    financing-amount: uint,
    discount-rate: uint,
    due-date: uint,
    status: uint,
    created-at: uint,
    funded-at: (optional uint),
    manager: principal
})

;; Invoice counter
(define-data-var invoice-counter uint u0)

;; Verify manager for this contract
(define-public (verify-invoice-manager (manager principal))
    (begin
        (map-set verified-managers manager true)
        (ok true)
    )
)

;; Check if manager is verified
(define-read-only (is-invoice-manager-verified (manager principal))
    (default-to false (map-get? verified-managers manager))
)

;; Create invoice financing request
(define-public (create-invoice-financing
    (buyer principal)
    (financier principal)
    (invoice-amount uint)
    (discount-rate uint)
    (due-date uint)
    (manager principal))
    (let ((invoice-id (+ (var-get invoice-counter) u1))
          (financing-amount (- invoice-amount (/ (* invoice-amount discount-rate) u10000))))
        (asserts! (is-invoice-manager-verified manager) ERR_MANAGER_NOT_VERIFIED)
        (asserts! (> invoice-amount u0) ERR_INVALID_INVOICE)
        (asserts! (and (>= discount-rate u100) (<= discount-rate u2000)) ERR_INVALID_DISCOUNT_RATE)
        (asserts! (> due-date block-height) ERR_INVOICE_EXPIRED)

        (map-set invoice-financing invoice-id {
            supplier: tx-sender,
            buyer: buyer,
            financier: financier,
            invoice-amount: invoice-amount,
            financing-amount: financing-amount,
            discount-rate: discount-rate,
            due-date: due-date,
            status: STATUS_PENDING,
            created-at: block-height,
            funded-at: none,
            manager: manager
        })

        (var-set invoice-counter invoice-id)
        (ok invoice-id)
    )
)

;; Approve invoice financing
(define-public (approve-invoice-financing (invoice-id uint))
    (let ((invoice (unwrap! (map-get? invoice-financing invoice-id) ERR_INVALID_INVOICE)))
        (asserts! (is-eq tx-sender (get financier invoice)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status invoice) STATUS_PENDING) ERR_INVALID_STATUS)
        (asserts! (> (get due-date invoice) block-height) ERR_INVOICE_EXPIRED)

        (map-set invoice-financing invoice-id (merge invoice {status: STATUS_APPROVED}))
        (ok true)
    )
)

;; Fund the invoice
(define-public (fund-invoice (invoice-id uint))
    (let ((invoice (unwrap! (map-get? invoice-financing invoice-id) ERR_INVALID_INVOICE)))
        (asserts! (is-eq tx-sender (get financier invoice)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status invoice) STATUS_APPROVED) ERR_INVALID_STATUS)
        (asserts! (> (get due-date invoice) block-height) ERR_INVOICE_EXPIRED)

        (map-set invoice-financing invoice-id (merge invoice {
            status: STATUS_FUNDED,
            funded-at: (some block-height)
        }))

        (ok (get financing-amount invoice))
    )
)

;; Repay invoice
(define-public (repay-invoice (invoice-id uint))
    (let ((invoice (unwrap! (map-get? invoice-financing invoice-id) ERR_INVALID_INVOICE)))
        (asserts! (is-eq tx-sender (get buyer invoice)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status invoice) STATUS_FUNDED) ERR_INVALID_STATUS)

        (map-set invoice-financing invoice-id (merge invoice {status: STATUS_REPAID}))
        (ok (get invoice-amount invoice))
    )
)

;; Mark invoice as defaulted
(define-public (mark-default (invoice-id uint))
    (let ((invoice (unwrap! (map-get? invoice-financing invoice-id) ERR_INVALID_INVOICE)))
        (asserts! (is-eq tx-sender (get financier invoice)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status invoice) STATUS_FUNDED) ERR_INVALID_STATUS)
        (asserts! (< (get due-date invoice) block-height) ERR_INVOICE_EXPIRED)

        (map-set invoice-financing invoice-id (merge invoice {status: STATUS_DEFAULTED}))
        (ok true)
    )
)

;; Get invoice financing details
(define-read-only (get-invoice-financing (invoice-id uint))
    (map-get? invoice-financing invoice-id)
)

;; Calculate financing amount
(define-read-only (calculate-financing-amount (invoice-amount uint) (discount-rate uint))
    (- invoice-amount (/ (* invoice-amount discount-rate) u10000))
)

;; Get current invoice counter
(define-read-only (get-invoice-counter)
    (var-get invoice-counter)
)
