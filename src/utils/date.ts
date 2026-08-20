export function formatDate(date: Date | string, lang: string = 'ru'): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  const options: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  };
  
  const locales: Record<string, string> = {
    ru: 'ru-RU',
    en: 'en-US',
    pl: 'pl-PL',
    by: 'be-BE',
  };
  
  return d.toLocaleDateString(locales[lang] || 'ru-RU', options);
}

export function formatDateShort(date: Date | string, lang: string = 'ru'): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  const options: Intl.DateTimeFormatOptions = {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  };
  
  const locales: Record<string, string> = {
    ru: 'ru-RU',
    en: 'en-US',
    pl: 'pl-PL',
    by: 'be-BE',
  };
  
  return d.toLocaleDateString(locales[lang] || 'ru-RU', options);
}
