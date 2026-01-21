;; Relief - Emergency Grant Distribution Protocol
;; A transparent aid distribution system for emergency response funding

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-insufficient-funds (err u103))
(define-constant err-unauthorized (err u104))
(define-constant err-already-disbursed (err u105))
(define-constant err-invalid-amount (err u106))

;; Data Variables
(define-data-var emergency-fund uint u0)

;; Data Maps
(define-map grants
    { grant-id: uint }
    {
        recipient: principal,
        amount: uint,
        purpose: (string-ascii 256),
        disbursed: bool,
        timestamp: uint,
        approved-by: principal
    }
)

(define-map authorized-distributors principal bool)

(define-data-var grant-nonce uint u0)

;; Authorization Functions
(define-public (add-distributor (distributor principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set authorized-distributors distributor true))
    )
)

(define-public (remove-distributor (distributor principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-delete authorized-distributors distributor))
    )
)

(define-read-only (is-authorized (distributor principal))
    (default-to false (map-get? authorized-distributors distributor))
)

;; Fund Management
(define-public (deposit-funds (amount uint))
    (begin
        (asserts! (> amount u0) err-invalid-amount)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (var-set emergency-fund (+ (var-get emergency-fund) amount))
        (ok amount)
    )
)

(define-read-only (get-fund-balance)
    (ok (var-get emergency-fund))
)

;; Grant Creation and Distribution
(define-public (create-grant (recipient principal) (amount uint) (purpose (string-ascii 256)))
    (let
        (
            (grant-id (+ (var-get grant-nonce) u1))
        )
        (asserts! (or (is-eq tx-sender contract-owner) (is-authorized tx-sender)) err-unauthorized)
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (<= amount (var-get emergency-fund)) err-insufficient-funds)
        
        (map-set grants
            { grant-id: grant-id }
            {
                recipient: recipient,
                amount: amount,
                purpose: purpose,
                disbursed: false,
                timestamp: stacks-block-height,
                approved-by: tx-sender
            }
        )
        (var-set grant-nonce grant-id)
        (ok grant-id)
    )
)

(define-public (disburse-grant (grant-id uint))
    (let
        (
            (grant (unwrap! (map-get? grants { grant-id: grant-id }) err-not-found))
        )
        (asserts! (or (is-eq tx-sender contract-owner) (is-authorized tx-sender)) err-unauthorized)
        (asserts! (is-eq (get disbursed grant) false) err-already-disbursed)
        (asserts! (<= (get amount grant) (var-get emergency-fund)) err-insufficient-funds)
        
        (try! (as-contract (stx-transfer? (get amount grant) tx-sender (get recipient grant))))
        
        (map-set grants
            { grant-id: grant-id }
            (merge grant { disbursed: true })
        )
        
        (var-set emergency-fund (- (var-get emergency-fund) (get amount grant)))
        (ok true)
    )
)

;; Read-only functions for transparency
(define-read-only (get-grant (grant-id uint))
    (ok (map-get? grants { grant-id: grant-id }))
)

(define-read-only (get-total-grants)
    (ok (var-get grant-nonce))
)

;; Emergency withdrawal (owner only, for fund recovery)
(define-public (emergency-withdraw (amount uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (<= amount (var-get emergency-fund)) err-insufficient-funds)
        (try! (as-contract (stx-transfer? amount tx-sender contract-owner)))
        (var-set emergency-fund (- (var-get emergency-fund) amount))
        (ok amount)
    )
)

;; Initialize contract owner as authorized distributor
(map-set authorized-distributors contract-owner true)