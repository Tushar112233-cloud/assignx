'use client';

import { cn } from '@/lib/utils';

interface UnreadIndicatorProps {
  count: number;
  position?: 'top-right' | 'top-left';
  animate?: boolean;
  className?: string;
}

export function UnreadIndicator({
  count,
  position = 'top-right',
  animate = true,
  className,
}: UnreadIndicatorProps) {
  if (count <= 0) return null;

  const displayCount = count > 99 ? '99+' : count.toString();

  return (
    <div
      className={cn(
        'absolute flex items-center justify-center',
        'min-w-[20px] h-5 px-1.5',
        'bg-gradient-to-r from-[#F97316] to-[#EA580C]',
        'text-white font-bold text-xs',
        'rounded-full',
        'shadow-lg shadow-orange-500/50',
        'transition-all duration-200',
        'hover:scale-110',
        animate && count > 0 && 'animate-pulse',
        position === 'top-right' && '-top-1 -right-1',
        position === 'top-left' && '-top-1 -left-1',
        className
      )}
      aria-label={`${count} unread message${count !== 1 ? 's' : ''}`}
      role="status"
    >
      {displayCount}
    </div>
  );
}
