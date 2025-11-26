import { db } from '../config/firebase.js';
import { SpotlightAudiobook } from '../models/SpotlightAudiobook.js';

const SPOTLIGHT_COLLECTION = 'spotlight_audiobooks';
const SNIPPETS_COLLECTION = 'audiobook_snippets';

/**
 * Get all active spotlight audiobooks with their snippet data
 */
export async function getActiveSpotlights(platform = 'all', targetAudience = 'all') {
  try {
    const spotlightsSnapshot = await db
      .collection(SPOTLIGHT_COLLECTION)
      .where('isActive', '==', true)
      .orderBy('priority', 'desc')
      .get();
    
    const spotlights = [];
    
    for (const doc of spotlightsSnapshot.docs) {
      const spotlight = SpotlightAudiobook.fromFirestore(doc);
      
      // Filter by target audience
      if (spotlight.targetAudience !== 'all' && spotlight.targetAudience !== targetAudience) {
        continue;
      }
      
      // Check date range
      if (!spotlight.isCurrentlyActive()) {
        continue;
      }
      
      // Fetch the associated audiobook snippet
      try {
        const snippetDoc = await db
          .collection(SNIPPETS_COLLECTION)
          .doc(spotlight.audiobookSnippetId)
          .get();
        
        if (snippetDoc.exists) {
          const snippetData = snippetDoc.data();
          spotlights.push({
            ...spotlight,
            snippet: {
              id: snippetDoc.id,
              ...snippetData,
            },
          });
        }
      } catch (error) {
        console.error(`Error fetching snippet for spotlight ${spotlight.id}:`, error);
      }
    }
    
    return spotlights;
  } catch (error) {
    // Handle NOT_FOUND errors (collection doesn't exist yet) gracefully
    if (error.code === 5 || error.message?.includes('NOT_FOUND')) {
      console.log('⚠️ Spotlight collection not found, returning empty array');
      return [];
    }
    console.error('❌ Error getting active spotlights:', error.message);
    // Return empty array instead of throwing to prevent API errors
    return [];
  }
}

/**
 * Get spotlight by ID
 */
export async function getSpotlightById(spotlightId) {
  try {
    const spotlightDoc = await db.collection(SPOTLIGHT_COLLECTION).doc(spotlightId).get();
    
    if (!spotlightDoc.exists) {
      return null;
    }
    
    const spotlight = SpotlightAudiobook.fromFirestore(spotlightDoc);
    
    // Fetch the associated snippet
    const snippetDoc = await db
      .collection(SNIPPETS_COLLECTION)
      .doc(spotlight.audiobookSnippetId)
      .get();
    
    if (snippetDoc.exists) {
      const snippetData = snippetDoc.data();
      return {
        ...spotlight,
        snippet: {
          id: snippetDoc.id,
          ...snippetData,
        },
      };
    }
    
    return spotlight;
  } catch (error) {
    console.error('Error getting spotlight by ID:', error);
    throw error;
  }
}

/**
 * Create a new spotlight
 */
export async function createSpotlight(spotlightData) {
  try {
    // Verify the snippet exists
    const snippetDoc = await db
      .collection(SNIPPETS_COLLECTION)
      .doc(spotlightData.audiobookSnippetId)
      .get();
    
    if (!snippetDoc.exists) {
      throw new Error('Audiobook snippet not found');
    }
    
    const spotlight = new SpotlightAudiobook(spotlightData);
    const spotlightRef = db.collection(SPOTLIGHT_COLLECTION).doc();
    spotlight.id = spotlightRef.id;
    
    await spotlightRef.set(spotlight.toFirestore());
    return spotlight;
  } catch (error) {
    console.error('Error creating spotlight:', error);
    throw error;
  }
}

/**
 * Update a spotlight
 */
export async function updateSpotlight(spotlightId, spotlightData) {
  try {
    const spotlightRef = db.collection(SPOTLIGHT_COLLECTION).doc(spotlightId);
    const existingDoc = await spotlightRef.get();
    
    if (!existingDoc.exists) {
      throw new Error('Spotlight not found');
    }
    
    const spotlight = SpotlightAudiobook.fromFirestore(existingDoc);
    Object.assign(spotlight, spotlightData);
    spotlight.updatedAt = new Date();
    
    await spotlightRef.update(spotlight.toFirestore());
    return spotlight;
  } catch (error) {
    console.error('Error updating spotlight:', error);
    throw error;
  }
}

/**
 * Delete a spotlight
 */
export async function deleteSpotlight(spotlightId) {
  try {
    await db.collection(SPOTLIGHT_COLLECTION).doc(spotlightId).delete();
    return { success: true };
  } catch (error) {
    console.error('Error deleting spotlight:', error);
    throw error;
  }
}

