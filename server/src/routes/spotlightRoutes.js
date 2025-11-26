import express from 'express';
import {
  getActiveSpotlights,
  getSpotlightById,
  createSpotlight,
  updateSpotlight,
  deleteSpotlight,
} from '../services/spotlightService.js';
import { body, param, validationResult } from 'express-validator';

const router = express.Router();

/**
 * GET /api/spotlight
 * Get all active spotlight audiobooks
 * Query params: platform (ios/android/all), targetAudience (all/new_users/premium)
 */
router.get('/', async (req, res) => {
  try {
    const platform = req.query.platform || 'all';
    const targetAudience = req.query.targetAudience || 'all';
    const spotlights = await getActiveSpotlights(platform, targetAudience);
    res.json(spotlights);
  } catch (error) {
    console.error('❌ Error getting spotlights:', error.message);
    // Return empty array instead of error to prevent app breakage
    res.json([]);
  }
});

/**
 * GET /api/spotlight/:id
 * Get spotlight by ID
 */
router.get('/:id', [param('id').notEmpty()], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const spotlight = await getSpotlightById(req.params.id);
    if (!spotlight) {
      return res.status(404).json({ error: 'Spotlight not found' });
    }
    res.json(spotlight);
  } catch (error) {
    console.error('Error getting spotlight:', error);
    res.status(500).json({ error: 'Failed to get spotlight' });
  }
});

/**
 * POST /api/spotlight
 * Create a new spotlight
 */
router.post(
  '/',
  [
    body('audiobookSnippetId').notEmpty(),
    body('priority').optional().isInt({ min: 0 }),
    body('isActive').optional().isBoolean(),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      
      const spotlight = await createSpotlight(req.body);
      res.status(201).json(spotlight);
    } catch (error) {
      console.error('Error creating spotlight:', error);
      if (error.message === 'Audiobook snippet not found') {
        return res.status(404).json({ error: error.message });
      }
      res.status(500).json({ error: 'Failed to create spotlight' });
    }
  }
);

/**
 * PUT /api/spotlight/:id
 * Update a spotlight
 */
router.put('/:id', [param('id').notEmpty()], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    const spotlight = await updateSpotlight(req.params.id, req.body);
    res.json(spotlight);
  } catch (error) {
    console.error('Error updating spotlight:', error);
    if (error.message === 'Spotlight not found') {
      return res.status(404).json({ error: error.message });
    }
    res.status(500).json({ error: 'Failed to update spotlight' });
  }
});

/**
 * DELETE /api/spotlight/:id
 * Delete a spotlight
 */
router.delete('/:id', [param('id').notEmpty()], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    
    await deleteSpotlight(req.params.id);
    res.json({ success: true });
  } catch (error) {
    console.error('Error deleting spotlight:', error);
    res.status(500).json({ error: 'Failed to delete spotlight' });
  }
});

export default router;

