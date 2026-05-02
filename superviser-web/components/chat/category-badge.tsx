import { User, UserCog, Users } from 'lucide-react';
import { cn } from '@/lib/utils';
import type { ChatRoomType } from '@/types/database';

interface CategoryBadgeProps {
  type: ChatRoomType;
  size?: 'sm' | 'md';
  showText?: boolean;
  className?: string;
}

const categoryConfig: Record<ChatRoomType, {
  label: string;
  icon: typeof User;
  bgColor: string;
  textColor: string;
}> = {
  project_user_supervisor: {
    label: 'User-Supervisor',
    icon: User,
    bgColor: 'bg-blue-100',
    textColor: 'text-blue-600',
  },
  project_supervisor_doer: {
    label: 'Supervisor-Doer',
    icon: UserCog,
    bgColor: 'bg-purple-100',
    textColor: 'text-purple-600',
  },
  project_all: {
    label: 'All Participants',
    icon: Users,
    bgColor: 'bg-emerald-100',
    textColor: 'text-emerald-600',
  },
  support: {
    label: 'Support',
    icon: UserCog,
    bgColor: 'bg-orange-100',
    textColor: 'text-orange-600',
  },
  direct: {
    label: 'Direct Message',
    icon: User,
    bgColor: 'bg-gray-100',
    textColor: 'text-gray-600',
  },
};

export function CategoryBadge({
  type,
  size = 'md',
  showText = false,
  className,
}: CategoryBadgeProps) {
  const config = categoryConfig[type];
  const Icon = config.icon;

  const sizeClasses = {
    sm: {
      container: 'h-5 px-1.5 gap-1',
      icon: 'h-3 w-3',
      text: 'text-xs',
    },
    md: {
      container: 'h-6 px-2 gap-1.5',
      icon: 'h-4 w-4',
      text: 'text-sm',
    },
  };

  return (
    <div
      className={cn(
        'inline-flex items-center rounded-full font-medium',
        config.bgColor,
        config.textColor,
        sizeClasses[size].container,
        className
      )}
    >
      <Icon className={sizeClasses[size].icon} />
      {showText && (
        <span className={sizeClasses[size].text}>{config.label}</span>
      )}
    </div>
  );
}
