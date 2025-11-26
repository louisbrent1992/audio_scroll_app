import express from 'express';
import { getAppConfig, updateAppConfig } from '../services/configService.js';
import { AppConfig } from '../models/AppConfig.js';
import { body, validationResult } from 'express-validator';

const router = express.Router();

/**
 * GET /api/config
 * Get current app configuration
 */
router.get('/', async (req, res) => {
  try {
    const config = await getAppConfig();
    // Convert to JSON format expected by client
    const configJson = {
      id: config.id,
      version: config.version,
      theme: config.theme,
      features: config.features,
      updatedAt: config.updatedAt instanceof Date 
        ? config.updatedAt.toISOString() 
        : new Date(config.updatedAt).toISOString(),
      createdAt: config.createdAt instanceof Date 
        ? config.createdAt.toISOString() 
        : new Date(config.createdAt).toISOString(),
    };
    res.json(configJson);
  } catch (error) {
    console.error('Error getting app config:', error);
    // Return a default config if Firestore fails
    try {
      const defaultConfig = new AppConfig({ id: 'default' });
      res.json({
        id: defaultConfig.id,
        version: defaultConfig.version,
        theme: defaultConfig.theme,
        features: defaultConfig.features,
        updatedAt: defaultConfig.updatedAt.toISOString(),
        createdAt: defaultConfig.createdAt.toISOString(),
      });
    } catch (fallbackError) {
      console.error('Error creating fallback config:', fallbackError);
      res.status(500).json({ 
        error: 'Failed to get app configuration',
        message: error.message 
      });
    }
  }
});

/**
 * PUT /api/config
 * Update app configuration
 */
router.put(
  '/',
  [
    body('theme').optional().isObject(),
    body('features').optional().isObject(),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
      
      const config = await updateAppConfig(req.body);
      res.json(config);
    } catch (error) {
      console.error('Error updating app config:', error);
      res.status(500).json({ error: 'Failed to update app configuration' });
    }
  }
);

export default router;

