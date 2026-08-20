export function formatDate(date: Date, lang: string): string {
  const options: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  };

  const locales: Record<string, string> = {
    ru: 'ru-RU',
    en: 'en-US',
    pl: 'pl-PL',
    by: 'be-BY',
  };

  return date.toLocaleDateString(locales[lang] || 'ru-RU', options);
}
