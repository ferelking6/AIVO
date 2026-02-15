-- ============================================
-- REVIEWS & RATINGS SYSTEM
-- ============================================

CREATE TABLE IF NOT EXISTS reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  title text,
  comment text,
  verified_purchase boolean DEFAULT false,
  helpful_count integer DEFAULT 0,
  unhelpful_count integer DEFAULT 0,
  created_at timestamp DEFAULT now(),
  updated_at timestamp DEFAULT now(),
  UNIQUE(product_id, user_id)
);

CREATE TABLE IF NOT EXISTS review_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  review_id uuid NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  created_at timestamp DEFAULT now()
);

-- ============================================
-- FLASH SALES & DEALS SYSTEM
-- ============================================

CREATE TABLE IF NOT EXISTS flash_sales (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id uuid NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  discount_percent numeric NOT NULL CHECK (discount_percent > 0 AND discount_percent <= 100),
  original_price numeric NOT NULL,
  sale_price numeric NOT NULL,
  started_at timestamp NOT NULL,
  ends_at timestamp NOT NULL,
  max_quantity integer,
  sold_quantity integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp DEFAULT now(),
  updated_at timestamp DEFAULT now()
);

-- ============================================
-- NOTIFICATION PREFERENCES
-- ============================================

CREATE TABLE IF NOT EXISTS notification_preferences (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  price_drop_alerts boolean DEFAULT true,
  back_in_stock_alerts boolean DEFAULT true,
  wishlist_alerts boolean DEFAULT true,
  deals_and_promotions boolean DEFAULT true,
  new_arrivals boolean DEFAULT true,
  personalized_recommendations boolean DEFAULT true,
  order_updates boolean DEFAULT true,
  created_at timestamp DEFAULT now(),
  updated_at timestamp DEFAULT now()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON reviews(product_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON reviews(rating DESC);
CREATE INDEX IF NOT EXISTS idx_flash_sales_product_id ON flash_sales(product_id);
CREATE INDEX IF NOT EXISTS idx_flash_sales_active_ends ON flash_sales(is_active, ends_at);
CREATE INDEX IF NOT EXISTS idx_notification_prefs_user ON notification_preferences(user_id);

-- ============================================
-- MATERIALIZED VIEW FOR PRODUCT RATINGS
-- ============================================

CREATE MATERIALIZED VIEW IF NOT EXISTS product_ratings_summary AS
SELECT
  p.id as product_id,
  COUNT(r.id) as total_reviews,
  ROUND(AVG(r.rating)::numeric, 2) as avg_rating,
  COUNT(CASE WHEN r.rating = 5 THEN 1 END) as five_star_count,
  COUNT(CASE WHEN r.rating = 4 THEN 1 END) as four_star_count,
  COUNT(CASE WHEN r.rating = 3 THEN 1 END) as three_star_count,
  COUNT(CASE WHEN r.rating = 2 THEN 1 END) as two_star_count,
  COUNT(CASE WHEN r.rating = 1 THEN 1 END) as one_star_count
FROM products p
LEFT JOIN reviews r ON p.id = r.product_id
GROUP BY p.id;

CREATE UNIQUE INDEX idx_product_ratings_summary_product_id
  ON product_ratings_summary(product_id);

-- ============================================
-- RPC FUNCTIONS FOR REVIEWS
-- ============================================

CREATE OR REPLACE FUNCTION add_review(
  p_product_id uuid,
  p_user_id uuid,
  p_rating integer,
  p_title text DEFAULT '',
  p_comment text DEFAULT '',
  p_verified_purchase boolean DEFAULT true
)
RETURNS TABLE (
  success boolean,
  message text,
  review_id uuid
) AS $$
DECLARE
  v_review_id uuid;
BEGIN
  INSERT INTO reviews (product_id, user_id, rating, title, comment, verified_purchase)
  VALUES (p_product_id, p_user_id, p_rating, p_title, p_comment, p_verified_purchase)
  RETURNING id INTO v_review_id;

  RETURN QUERY SELECT true, 'Review added successfully'::text, v_review_id;
EXCEPTION WHEN unique_violation THEN
  RETURN QUERY SELECT false, 'You already reviewed this product'::text, NULL::uuid;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_product_reviews(
  p_product_id uuid DEFAULT NULL,
  p_rating_filter integer DEFAULT NULL,
  p_limit integer DEFAULT 10,
  p_offset integer DEFAULT 0
)
RETURNS TABLE (
  review_id uuid,
  user_name text,
  rating integer,
  title text,
  comment text,
  verified_purchase boolean,
  helpful_count integer,
  created_at timestamp,
  images text[]
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    u.email::text,
    r.rating,
    r.title,
    r.comment,
    r.verified_purchase,
    r.helpful_count,
    r.created_at,
    ARRAY_AGG(ri.image_url) FILTER (WHERE ri.image_url IS NOT NULL)
  FROM reviews r
  LEFT JOIN review_images ri ON r.id = ri.review_id
  LEFT JOIN auth.users u ON r.user_id = u.id
  WHERE (p_product_id IS NULL OR r.product_id = p_product_id)
    AND (p_rating_filter IS NULL OR r.rating = p_rating_filter)
  GROUP BY r.id, u.email, r.rating, r.title, r.comment, r.verified_purchase, r.helpful_count, r.created_at
  ORDER BY r.helpful_count DESC, r.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- RPC FUNCTIONS FOR FLASH SALES
-- ============================================

CREATE OR REPLACE FUNCTION get_active_flash_sales(
  p_limit integer DEFAULT 20
)
RETURNS TABLE (
  sale_id uuid,
  product_id uuid,
  product_title text,
  category_name text,
  discount_percent numeric,
  original_price numeric,
  sale_price numeric,
  ends_at timestamp,
  time_remaining text,
  max_quantity integer,
  sold_quantity integer,
  stock_available integer,
  image_url text
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    fs.id,
    fs.product_id,
    p.title,
    c.name,
    fs.discount_percent,
    fs.original_price,
    fs.sale_price,
    fs.ends_at,
    to_char(fs.ends_at - now(), 'HH24h MI"m"') as time_remaining,
    fs.max_quantity,
    fs.sold_quantity,
    p.stock - COALESCE(fs.sold_quantity, 0),
    p.image_url
  FROM flash_sales fs
  JOIN products p ON fs.product_id = p.id
  LEFT JOIN categories c ON fs.category_id = c.id
  WHERE fs.is_active = true
    AND fs.ends_at > now()
    AND p.stock > 0
  ORDER BY fs.ends_at ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- RPC FUNCTION FOR NOTIFICATION PREFERENCES
-- ============================================

CREATE OR REPLACE FUNCTION upsert_notification_preferences(
  p_user_id uuid,
  p_price_drop_alerts boolean DEFAULT true,
  p_back_in_stock_alerts boolean DEFAULT true,
  p_wishlist_alerts boolean DEFAULT true,
  p_deals_and_promotions boolean DEFAULT true,
  p_new_arrivals boolean DEFAULT true,
  p_personalized_recommendations boolean DEFAULT true,
  p_order_updates boolean DEFAULT true
)
RETURNS TABLE (
  success boolean,
  message text
) AS $$
BEGIN
  INSERT INTO notification_preferences (
    user_id, price_drop_alerts, back_in_stock_alerts, wishlist_alerts,
    deals_and_promotions, new_arrivals, personalized_recommendations, order_updates
  ) VALUES (
    p_user_id, p_price_drop_alerts, p_back_in_stock_alerts, p_wishlist_alerts,
    p_deals_and_promotions, p_new_arrivals, p_personalized_recommendations, p_order_updates
  )
  ON CONFLICT (user_id) DO UPDATE SET
    price_drop_alerts = p_price_drop_alerts,
    back_in_stock_alerts = p_back_in_stock_alerts,
    wishlist_alerts = p_wishlist_alerts,
    deals_and_promotions = p_deals_and_promotions,
    new_arrivals = p_new_arrivals,
    personalized_recommendations = p_personalized_recommendations,
    order_updates = p_order_updates,
    updated_at = now();

  RETURN QUERY SELECT true, 'Preferences updated'::text;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_notification_preferences(
  p_user_id uuid DEFAULT NULL
)
RETURNS TABLE (
  user_id uuid,
  price_drop_alerts boolean,
  back_in_stock_alerts boolean,
  wishlist_alerts boolean,
  deals_and_promotions boolean,
  new_arrivals boolean,
  personalized_recommendations boolean,
  order_updates boolean
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    np.user_id,
    np.price_drop_alerts,
    np.back_in_stock_alerts,
    np.wishlist_alerts,
    np.deals_and_promotions,
    np.new_arrivals,
    np.personalized_recommendations,
    np.order_updates
  FROM notification_preferences np
  WHERE (p_user_id IS NULL OR np.user_id = p_user_id)
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;
