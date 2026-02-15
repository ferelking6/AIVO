-- ============================================
-- SEED DATA - Sample Products, Categories, etc
-- ============================================

-- Insert Categories
INSERT INTO categories (id, name, icon_url) VALUES
  ('cat-001', 'Electronics', 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=200'),
  ('cat-002', 'Fashion', 'https://images.unsplash.com/photo-1505521585163-fcf4ee5dbe83?w=200'),
  ('cat-003', 'Home & Living', 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=200'),
  ('cat-004', 'Sports & Outdoors', 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=200'),
  ('cat-005', 'Beauty & Personal Care', 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=200')
ON CONFLICT (id) DO NOTHING;

-- Insert Products (20 sample products)
INSERT INTO products (id, title, description, category_id, tags, brand, price, currency, stock, active, image_url, created_at) VALUES
  -- Electronics
  ('prod-001', 'Wireless Headphones Pro', 'Premium noise-cancelling headphones with 30hr battery', 'cat-001', ARRAY['audio', 'wireless', 'premium'], 'AudioTech', 199.99, 'USD', 45, true, 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400', NOW()),
  ('prod-002', 'Smart Watch Ultra', 'Advanced fitness tracking and health monitoring', 'cat-001', ARRAY['wearable', 'fitness', 'smart'], 'TechBrand', 349.99, 'USD', 32, true, 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400', NOW()),
  ('prod-003', 'USB-C Fast Charger', '65W fast charging for all devices', 'cat-001', ARRAY['charger', 'usb-c', 'fast'], 'PowerTech', 49.99, 'USD', 120, true, 'https://images.unsplash.com/photo-1592286927505-1def25115558?w=400', NOW()),
  ('prod-004', '4K Webcam', 'Professional streaming camera with auto-focus', 'cat-001', ARRAY['camera', '4k', 'streaming'], 'VisionPro', 129.99, 'USD', 28, true, 'https://images.unsplash.com/photo-1598327105666-5b89351aff97?w=400', NOW()),

  -- Fashion
  ('prod-005', 'Premium Denim Jacket', 'Classic blue denim with modern fit', 'cat-002', ARRAY['jacket', 'denim', 'casual'], 'StyleBrand', 99.99, 'USD', 65, true, 'https://images.unsplash.com/photo-1495180044369-402848c30700?w=400', NOW()),
  ('prod-006', 'Leather Sneakers', 'Comfortable everyday sneakers with premium leather', 'cat-002', ARRAY['shoes', 'sneakers', 'leather'], 'FootGear', 129.99, 'USD', 50, true, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400', NOW()),
  ('prod-007', 'Cotton T-Shirt Pack', 'Set of 3 premium cotton t-shirts', 'cat-002', ARRAY['tshirt', 'cotton', 'basic'], 'ComfortWear', 49.99, 'USD', 200, true, 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400', NOW()),
  ('prod-008', 'Wool Beanie', 'Warm winter beanie in multiple colors', 'cat-002', ARRAY['hat', 'winter', 'wool'], 'WarmStyle', 29.99, 'USD', 95, true, 'https://images.unsplash.com/photo-1572582533383-a173fc0b5c79?w=400', NOW()),

  -- Home & Living
  ('prod-009', 'Coffee Maker Deluxe', 'Programmable coffee maker with thermal carafe', 'cat-003', ARRAY['kitchen', 'coffee', 'appliance'], 'HomePerfect', 89.99, 'USD', 38, true, 'https://images.unsplash.com/photo-1517668808822-9ebb02ae2a0e?w=400', NOW()),
  ('prod-010', 'Bamboo Cutting Board Set', 'Set of 3 durable cutting boards', 'cat-003', ARRAY['kitchen', 'bamboo', 'cooking'], 'EcoHome', 39.99, 'USD', 110, true, 'https://images.unsplash.com/photo-1585521585265-d7a70120e221?w=400', NOW()),
  ('prod-011', 'LED Smart Light Bulbs', 'WiFi enabled RGB light bulbs (4-pack)', 'cat-003', ARRAY['lighting', 'smart', 'energy-efficient'], 'SmartHome', 59.99, 'USD', 75, true, 'https://images.unsplash.com/photo-1565636192292-183c5a6a9cff?w=400', NOW()),
  ('prod-012', 'Yoga Mat Premium', 'Non-slip yoga mat with carrying strap', 'cat-003', ARRAY['fitness', 'yoga', 'exercise'], 'FitLiving', 49.99, 'USD', 85, true, 'https://images.unsplash.com/photo-1601925260368-ae2f83cf8b7f?w=400', NOW()),

  -- Sports & Outdoors
  ('prod-013', 'Mountain Bike Helmet', 'Safety certified bike helmet with ventilation', 'cat-004', ARRAY['sports', 'bike', 'safety'], 'SportGear', 79.99, 'USD', 42, true, 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', NOW()),
  ('prod-014', 'Running Shoes Pro', 'Professional grade running shoes with gel insoles', 'cat-004', ARRAY['shoes', 'sports', 'running'], 'SportFit', 149.99, 'USD', 55, true, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400', NOW()),
  ('prod-015', 'Camping Tent 4-Person', 'Waterproof camping tent with easy setup', 'cat-004', ARRAY['camping', 'outdoor', 'tent'], 'OutdoorCo', 199.99, 'USD', 20, true, 'https://images.unsplash.com/photo-1478131143081-80f7f84ca84d?w=400', NOW()),
  ('prod-016', 'Kayak Paddle Set', 'Lightweight aluminum kayak paddles (2-pack)', 'cat-004', ARRAY['water-sports', 'kayak', 'outdoor'], 'WaterSports', 99.99, 'USD', 15, true, 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400', NOW()),

  -- Beauty & Personal Care
  ('prod-017', 'Organic Skincare Set', 'Complete skincare routine: cleanser, toner, moisturizer', 'cat-005', ARRAY['skincare', 'organic', 'beauty'], 'BeautyNatural', 79.99, 'USD', 88, true, 'https://images.unsplash.com/photo-1556228578-8c89e6adf883?w=400', NOW()),
  ('prod-018', 'Anti-Aging Face Serum', 'Lightweight serum with hyaluronic acid', 'cat-005', ARRAY['serum', 'anti-aging', 'skincare'], 'SkinCare+', 49.99, 'USD', 60, true, 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=400', NOW()),
  ('prod-019', 'Hair Growth Shampoo', 'Biotin-enriched hair strengthening shampoo', 'cat-005', ARRAY['haircare', 'shampoo', 'growth'], 'HairPro', 24.99, 'USD', 150, true, 'https://images.unsplash.com/photo-1585862305503-29a16ba11340?w=400', NOW()),
  ('prod-020', 'Beard Care Kit', 'Complete beard grooming set with oils and brush', 'cat-005', ARRAY['grooming', 'beard', 'men'], 'GroomingCo', 39.99, 'USD', 75, true, 'https://images.unsplash.com/photo-1596462502278-af242a8ae1c7?w=400', NOW());

-- Product Affinities (Accessories & Related Products)
INSERT INTO product_affinities (source_product_id, target_product_id, reason, strength) VALUES
  -- Headphones → Charger, Phone case
  ('prod-001', 'prod-003', 'accessory', 8),
  ('prod-001', 'prod-004', 'compatibility', 6),

  -- Smart Watch → Charger
  ('prod-002', 'prod-003', 'accessory', 9),

  -- Denim Jacket → Sneakers
  ('prod-005', 'prod-006', 'compatibility', 8),
  ('prod-005', 'prod-008', 'accessory', 7),

  -- Sneakers → T-Shirt
  ('prod-006', 'prod-007', 'compatibility', 7),

  -- Coffee Maker → Cutting Board (home goods)
  ('prod-009', 'prod-010', 'compatibility', 5),

  -- Mountain Bike Helmet → Running Shoes
  ('prod-013', 'prod-014', 'compatibility', 6),

  -- Camping Tent → Kayak Paddle
  ('prod-015', 'prod-016', 'compatibility', 8),

  -- Skincare Set → Hair Serum
  ('prod-017', 'prod-018', 'accessory', 7),
  ('prod-017', 'prod-019', 'compatibility', 6),

  -- Beard Kit → Hair Growth Shampoo
  ('prod-020', 'prod-019', 'compatibility', 7);

-- Trending Products (Sample trending data for US)
INSERT INTO trending_products (country, city, category_id, product_id, score) VALUES
  ('US', NULL, 'cat-001', 'prod-001', 95.5),
  ('US', NULL, 'cat-001', 'prod-002', 88.3),
  ('US', NULL, 'cat-002', 'prod-005', 82.1),
  ('US', NULL, 'cat-002', 'prod-006', 78.9),
  ('US', NULL, 'cat-003', 'prod-009', 75.4),
  ('US', NULL, 'cat-004', 'prod-013', 72.6),
  ('US', NULL, 'cat-005', 'prod-017', 85.2),

  ('CA', NULL, 'cat-001', 'prod-002', 92.1),
  ('CA', NULL, 'cat-002', 'prod-008', 84.5),
  ('CA', NULL, 'cat-004', 'prod-015', 86.7),

  ('UK', NULL, 'cat-001', 'prod-001', 89.3),
  ('UK', NULL, 'cat-002', 'prod-005', 80.2),
  ('UK', NULL, 'cat-005', 'prod-018', 83.4);

-- Product Pairs (Co-occurrence data)
INSERT INTO product_pairs (product_id, paired_product_id, pair_count, score) VALUES
  ('prod-001', 'prod-003', 45, 92.5),
  ('prod-002', 'prod-003', 38, 88.3),
  ('prod-005', 'prod-006', 62, 97.2),
  ('prod-006', 'prod-007', 58, 95.1),
  ('prod-009', 'prod-010', 34, 82.4),
  ('prod-013', 'prod-014', 29, 86.5),
  ('prod-015', 'prod-016', 18, 89.3),
  ('prod-017', 'prod-018', 47, 94.6);

COMMIT;
