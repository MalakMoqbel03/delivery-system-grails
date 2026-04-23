package com.ubs.delivery

/**
 * User domain — minimized schema.
 *
 * WHY THESE FIELDS AND NOT OTHERS?
 * ─────────────────────────────────────────────────────────────────
 * Data minimization (GDPR Art. 5(1)(c)) requires you to collect only what is
 * "adequate, relevant and limited to what is necessary." So we never persist:
 *
 *   ✗  fullAddress   — street + building is too precise; city is enough for delivery
 *   ✗  dateOfBirth   — full DOB is not needed; birth YEAR is enough for age checks
 *   ✗  rawPhone      — we only need to check uniqueness; a hash covers that
 *
 * What we DO store, and why:
 *
 *   username   — identity token, used for login
 *   password   — BCrypt hash (irreversible, salted) — AuthService handles this
 *   role       — access-control decision
 *   email      — AES-256-GCM encrypted (see EncryptionService)
 *                Encrypted because: we need to send emails (reversible), but
 *                the column at rest must not be readable from a DB dump.
 *   phoneHash  — HMAC-SHA-256 with pepper (irreversible)
 *                Stored as a 64-char hex string so deduplication queries work:
 *                  SELECT * FROM delivery_user WHERE phone_hash = ?
 *                without ever holding the raw number.
 *   birthYear  — integer year only (e.g. 1990), NOT full date
 *                Enables age-range analytics without exposing exact birthday.
 *   city       — city only, NOT full address
 *                Enables region analytics and delivery routing.
 *   pseudoId   — random UUID assigned at registration by DataMinimizationService
 *                Used in external systems / logs so the real DB id is not exposed.
 *   enabled / createdAt / lastLoginAt — operational metadata
 *
 * FIELD-LEVEL TECHNIQUE SUMMARY:
 *   email      → AES-256-GCM encryption     (reversible, key-protected)
 *   phoneHash  → HMAC-SHA-256 + pepper       (one-way, deduplication-safe)
 *   birthYear  → minimization (year only)    (less precise than full DOB)
 *   city       → minimization (city only)    (less precise than full address)
 *   pseudoId   → pseudonymization            (decoupled from real identity)
 *   password   → BCrypt hash                 (handled by AuthService, unchanged)
 */
class User {

    // ── core auth ─────────────────────────────────────────────────────────────
    String  username
    String  password
    String  role
    boolean enabled = true

    byte[]  email
    String  phoneHash
    Integer birthYear
    String  city
    String  pseudoId
    Date    createdAt   = new Date()
    Date    lastLoginAt
    boolean anonymized  = false

    static constraints = {
        username    nullable: false, blank: false, unique: true, size: 3..50
        password    nullable: false, blank: false
        role        nullable: false, blank: false, inList: ['ADMIN', 'USER', 'SUPPORT', 'ANALYST']
        email       nullable: true
        phoneHash   nullable: true, maxSize: 64
        birthYear   nullable: true, min: 1900, max: 2100
        city        nullable: true,  maxSize: 100
        pseudoId    nullable: true,  maxSize: 36, unique: true
        createdAt   nullable: false
        lastLoginAt nullable: true
        anonymized  nullable: false
    }

    static mapping = {
        version  false
        table    'delivery_user'
        password column: 'user_password'
        email    sqlType: 'bytea'
        phoneHash column: 'phone_hash'
        birthYear column: 'birth_year'
        pseudoId  column: 'pseudo_id'
        lastLoginAt column: 'last_login_at'
        createdAt   column: 'created_at'
    }
}