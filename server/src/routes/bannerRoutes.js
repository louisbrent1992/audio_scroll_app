import express from 'express';
import {
  getActiveBanners,
  getBannerById,
  createBanner,
  updateBanner,
  deleteBanner,
} from '../services/bannerService.js';
import { body, param, validationResult } from 'express-validator';

const router = express.Router();

/**
 * GET /api/banners
 * Get all active banners
 * Query params: platform (ios/android/all), targetAudience (all/new_users/premium)
 */
router.get('/', async (req, res) => {
  try {
    const platform = req.query.platform || 'all';
    const targetAudience = req.query.targetAudience || 'all';
    const banners = await getActiveBanners(platform, targetAudience);
    res.json(banners);
  } catch (error) {
    console.error('❌ Error getting banners:', error.message);
    // Return empty array instead of error to prevent app breakage
    res.json([]);
  }
});

/**
 * GET /api/banners/:id
 * Get banner by ID
 */
router.get('/:id', [param('id').notEmpty()], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const banner = await getBannerById(req.params.id);
    if (!banner) {
      return res.status(404).json({ error: 'Banner not found' });
    }
    res.json(banner);
  } catch (error) {
    console.error('Error getting banner:', error);
    res.status(500).json({ error: 'Failed to get banner' });
  }
});

/**
 * POST /api/banners
 * Create a new banner
 */
router.post(
  '/',
  [
    body('title').notEmpty().trim(),
    body('imageUrl').isURL(),
    body('priority').optional().isInt({ min: 0 }),
    body('isActive').optional().isBoolean(),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      
      const banner = await createBanner(req.body);
      res.status(201).json(banner);
    } catch (error) {
      console.error('Error creating banner:', error);
      res.status(500).json({ error: 'Failed to create banner' });
    }
  }
);

/**
 * PUT /api/banners/:id
 * Update a banner
 */
router.put('/:id', [param('id').notEmpty()], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const banner = await updateBanner(req.params.id, req.body);
    res.json(banner);
  } catch (error) {
    console.error('Error updating banner:', error);
    if (error.message === 'Banner not found') {
      return res.status(404).json({ error: error.message });
    }
    res.status(500).json({ error: 'Failed to update banner' });
  }
});

/**
 * DELETE /api/banners/:id
 * Delete a banner
 */
router.delete('/:id', [param('id').notEmpty()], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    await deleteBanner(req.params.id);
    res.json({ success: true });
  } catch (error) {
    console.error('Error deleting banner:', error);
    res.status(500).json({ error: 'Failed to delete banner' });
  }
});

export default router;

