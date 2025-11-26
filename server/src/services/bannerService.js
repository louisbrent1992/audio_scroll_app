import { db } from '../config/firebase.js';
import { Banner } from '../models/Banner.js';

const BANNERS_COLLECTION = 'banners';

/**
 * Get all active banners
 */
export async function getActiveBanners(platform = 'all', targetAudience = 'all') {
  try {
    const bannersSnapshot = await db
      .collection(BANNERS_COLLECTION)
      .where('isActive', '==', true)
      .orderBy('priority', 'desc')
      .get();
    
    const banners = [];
    
    bannersSnapshot.forEach((doc) => {
      const banner = Banner.fromFirestore(doc);
      
      // Filter by platform
      if (banner.platform !== 'all' && banner.platform !== platform) {
        return;
      }
      
      // Filter by target audience
      if (banner.targetAudience !== 'all' && banner.targetAudience !== targetAudience) {
        return;
      }
      
      // Check date range
      if (banner.isCurrentlyActive()) {
        banners.push(banner);
      }
    });
    
    return banners;
  } catch (error) {
    // Handle NOT_FOUND errors (collection doesn't exist yet) gracefully
    if (error.code === 5 || error.message?.includes('NOT_FOUND')) {
      console.log('⚠️ Banners collection not found, returning empty array');
      return [];
    }
    console.error('❌ Error getting active banners:', error.message);
    // Return empty array instead of throwing to prevent API errors
    return [];
  }
}

/**
 * Get banner by ID
 */
export async function getBannerById(bannerId) {
  try {
    const bannerDoc = await db.collection(BANNERS_COLLECTION).doc(bannerId).get();
    
    if (!bannerDoc.exists) {
      return null;
    }
    
    return Banner.fromFirestore(bannerDoc);
  } catch (error) {
    console.error('Error getting banner by ID:', error);
    throw error;
  }
}

/**
 * Create a new banner
 */
export async function createBanner(bannerData) {
  try {
    const banner = new Banner(bannerData);
    const bannerRef = db.collection(BANNERS_COLLECTION).doc();
    banner.id = bannerRef.id;
    
    await bannerRef.set(banner.toFirestore());
    return banner;
  } catch (error) {
    console.error('Error creating banner:', error);
    throw error;
  }
}

/**
 * Update a banner
 */
export async function updateBanner(bannerId, bannerData) {
  try {
    const bannerRef = db.collection(BANNERS_COLLECTION).doc(bannerId);
    const existingDoc = await bannerRef.get();
    
    if (!existingDoc.exists) {
      throw new Error('Banner not found');
    }
    
    const banner = Banner.fromFirestore(existingDoc);
    Object.assign(banner, bannerData);
    banner.updatedAt = new Date();
    
    await bannerRef.update(banner.toFirestore());
    return banner;
  } catch (error) {
    console.error('Error updating banner:', error);
    throw error;
  }
}

/**
 * Delete a banner
 */
export async function deleteBanner(bannerId) {
  try {
    await db.collection(BANNERS_COLLECTION).doc(bannerId).delete();
    return { success: true };
  } catch (error) {
    console.error('Error deleting banner:', error);
    throw error;
  }
}

