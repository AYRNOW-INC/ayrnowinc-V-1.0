-- V2: Add Stripe-specific fields and idempotency support to payments

ALTER TABLE payments ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'usd';
ALTER TABLE payments ADD COLUMN IF NOT EXISTS stripe_event_id VARCHAR(255);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS stripe_customer_id VARCHAR(255);
ALTER TABLE payments ADD COLUMN IF NOT EXISTS description TEXT;

-- Index for idempotent webhook processing
CREATE UNIQUE INDEX IF NOT EXISTS idx_payments_stripe_event ON payments(stripe_event_id) WHERE stripe_event_id IS NOT NULL;
