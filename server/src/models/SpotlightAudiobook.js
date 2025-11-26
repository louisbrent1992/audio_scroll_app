/**
 * Spotlight Audiobook Model
 * Featured audiobooks that can be promoted without app rebuilds
 */
export class SpotlightAudiobook {
  constructor(data) {
    this.id = data.id;
    this.audiobookSnippetId = data.audiobookSnippetId; // Reference to the audiobook snippet
    this.title = data.title || '';
    this.priority = data.priority || 0; // Higher priority = shown first
    this.isActive = data.isActive ?? true;
    this.startDate = data.startDate ? new Date(data.startDate) : new Date();
    this.endDate = data.endDate ? new Date(data.endDate) : null;
    this.promotionText = data.promotionText || ''; // Custom promotion message
    this.badge = data.badge || null; // e.g., "New Release", "Editor's Pick"
    this.targetAudience = data.targetAudience || 'all';
    this.createdAt = data.createdAt || new Date();
    this.updatedAt = data.updatedAt || new Date();
  }

  toFirestore() {
    return {
      audiobookSnippetId: this.audiobookSnippetId,
      title: this.title,
      priority: this.priority,
      isActive: this.isActive,
      startDate: this.startDate,
      endDate: this.endDate,
      promotionText: this.promotionText,
      badge: this.badge,
      targetAudience: this.targetAudience,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }

  static fromFirestore(doc) {
    const data = doc.data();
    return new SpotlightAudiobook({
      id: doc.id,
      ...data,
    });
  }

  isCurrentlyActive() {
    if (!this.isActive) return false;
    const now = new Date();
    if (now < this.startDate) return false;
    if (this.endDate && now > this.endDate) return false;
    return true;
  }
}

