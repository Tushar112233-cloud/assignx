export const isValidEmail = (email: string): boolean => {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
};

export const sanitizeString = (str: string): string => {
  return str.trim().replace(/<[^>]*>/g, '');
};
