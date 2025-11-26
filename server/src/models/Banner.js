/**
 * Banner Model
 * Dynamic promotional banners that can be updated without app rebuilds
 */
export class Banner {
  constructor(data) {
    this.id = data.id;
    this.title = data.title || '';
    this.subtitle = data.subtitle || '';
    this.imageUrl = data.imageUrl || '';
    this.actionUrl = data.actionUrl || '';
    this.actionText = data.actionText || 'Learn More';
    this.priority = data.priority || 0; // Higher priority = shown first
    this.isActive = data.isActive ?? true;
    this.startDate = data.startDate ? new Date(data.startDate) : new Date();
    this.endDate = data.endDate ? new Date(data.endDate) : null;
    this.targetAudience = data.targetAudience || 'all'; // 'all', 'new_users', 'premium'
    this.platform = data.platform || 'all'; // 'all', 'ios', 'android'
    this.createdAt = data.createdAt || new Date();
    this.updatedAt = data.updatedAt || new Date();
  }

  toFirestore() {
    return {
      title: this.title,
      subtitle: this.subtitle,
      imageUrl: this.imageUrl,
      actionUrl: this.actionUrl,
      actionText: this.actionText,
      priority: this.priority,
      isActive: this.isActive,
      startDate: this.startDate,
      endDate: this.endDate,
      targetAudience: this.targetAudience,
      platform: this.platform,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }

  static fromFirestore(doc) {
    const data = doc.data();
    return new Banner({
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

