/**
 * App Configuration Model
 * Stores dynamic theme and UI settings that can be updated without app rebuilds
 */
export class AppConfig {
  constructor(data) {
    this.id = data.id || 'default';
    this.version = data.version || 1;
    this.theme = {
      primaryColor: data.theme?.primaryColor || '#1A1A2E',
      secondaryColor: data.theme?.secondaryColor || '#16213E',
      accentColor: data.theme?.accentColor || '#0F3460',
      highlightColor: data.theme?.highlightColor || '#E94560',
      surfaceColor: data.theme?.surfaceColor || '#0F0F1E',
      backgroundColor: data.theme?.backgroundColor || '#000000',
      textPrimary: data.theme?.textPrimary || '#FFFFFF',
      textSecondary: data.theme?.textSecondary || '#B0B0B0',
      textTertiary: data.theme?.textTertiary || '#808080',
    };
    this.features = {
      enableBanners: data.features?.enableBanners ?? true,
      enableSpotlight: data.features?.enableSpotlight ?? true,
      enableOnboarding: data.features?.enableOnboarding ?? true,
      maxSnippetDuration: data.features?.maxSnippetDuration || 90,
      minSnippetDuration: data.features?.minSnippetDuration || 30,
    };
    this.updatedAt = data.updatedAt || new Date();
    this.createdAt = data.createdAt || new Date();
  }

  toFirestore() {
    return {
      version: this.version,
      theme: this.theme,
      features: this.features,
      updatedAt: this.updatedAt,
      createdAt: this.createdAt,
    };
  }

  static fromFirestore(doc) {
    const data = doc.data();
    return new AppConfig({
      id: doc.id,
      ...data,
    });
  }
}

