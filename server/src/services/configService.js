import { db } from '../config/firebase.js';
import { AppConfig } from '../models/AppConfig.js';

const CONFIG_COLLECTION = 'app_config';

/**
 * Get the current app configuration
 */
export async function getAppConfig() {
  try {
    const configRef = db.collection(CONFIG_COLLECTION).doc('default');
    const configDoc = await configRef.get();
    
    if (!configDoc.exists) {
      // Create default config if it doesn't exist
      console.log('Creating default app config in Firestore...');
      try {
        const defaultConfig = new AppConfig({ id: 'default' });
        await configRef.set(defaultConfig.toFirestore());
        console.log('✅ Default app config created successfully');
        return defaultConfig;
      } catch (createError) {
        console.error('❌ Error creating default config in Firestore:', createError);
        // Return default config object even if Firestore write fails
        console.log('⚠️ Returning default config object (not persisted)');
        return new AppConfig({ id: 'default' });
      }
    }
    
    return AppConfig.fromFirestore(configDoc);
  } catch (error) {
    // Handle any Firestore errors
    console.error('❌ Error getting app config from Firestore:', error.message);
    console.log('⚠️ Returning default config object (Firestore unavailable)');
    
    // Return default config even if Firestore fails
    // This allows the app to work even if Firestore has issues
    return new AppConfig({ id: 'default' });
  }
}

/**
 * Update app configuration
 */
export async function updateAppConfig(configData) {
  try {
    const configRef = db.collection(CONFIG_COLLECTION).doc('default');
    const existingDoc = await configRef.get();
    
    let config;
    if (existingDoc.exists) {
      config = AppConfig.fromFirestore(existingDoc);
      // Update fields
      if (configData.theme) {
        config.theme = { ...config.theme, ...configData.theme };
      }
      if (configData.features) {
        config.features = { ...config.features, ...configData.features };
      }
      config.version = (config.version || 0) + 1;
      config.updatedAt = new Date();
    } else {
      config = new AppConfig({ ...configData, id: 'default' });
    }
    
    await configRef.set(config.toFirestore());
    return config;
  } catch (error) {
    console.error('Error updating app config:', error);
    throw error;
  }
}

