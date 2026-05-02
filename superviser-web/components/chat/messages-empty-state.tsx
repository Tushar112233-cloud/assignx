'use client';

import { motion } from 'framer-motion';
import { MessageSquare, Search, Filter, MessageSquarePlus } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { MessageIllustration } from './message-illustration';

interface MessagesEmptyStateProps {
  searchQuery?: string;
  activeFilter?: string;
  onStartConversation?: () => void;
}

export function MessagesEmptyState({
  searchQuery,
  activeFilter,
  onStartConversation,
}: MessagesEmptyStateProps) {
  // Determine content based on context
  const getContent = () => {
    if (searchQuery) {
      return {
        title: 'No conversations found',
        subtitle: `We couldn't find any conversations matching "${searchQuery}". Try adjusting your search terms.`,
        icon: Search,
        showIllustration: false,
        showCTA: false,
      };
    }

    if (activeFilter && activeFilter !== 'all') {
      const filterLabel = activeFilter.charAt(0).toUpperCase() + activeFilter.slice(1);
      return {
        title: `No ${filterLabel.toLowerCase()} messages`,
        subtitle: `There are no conversations with this filter. Try selecting a different filter or start a new conversation.`,
        icon: Filter,
        showIllustration: false,
        showCTA: false,
      };
    }

    return {
      title: 'No messages yet',
      subtitle: 'Your conversations will appear here once you start chatting.',
      icon: MessageSquare,
      showIllustration: true,
      showCTA: true,
    };
  };

  const content = getContent();
  const Icon = content.icon;

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration: 0.3 }}
      className="flex flex-col items-center justify-center p-12 text-center min-h-[400px]"
    >
      <div className="relative">
        <div className="absolute inset-0 bg-gradient-to-r from-orange-500/10 via-transparent to-orange-500/10 rounded-full blur-3xl" />

        {/* Show illustration only for main empty state */}
        {content.showIllustration ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.4, delay: 0.1 }}
            className="relative mb-6"
          >
            <div className="w-24 h-24 rounded-3xl bg-gradient-to-br from-orange-50 to-amber-50 border-2 border-orange-100 flex items-center justify-center mx-auto shadow-lg shadow-orange-500/10">
              <Icon className="h-12 w-12 text-orange-500" />
            </div>
          </motion.div>
        ) : (
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.3, delay: 0.1 }}
            className="relative w-20 h-20 rounded-2xl bg-gradient-to-br from-gray-100 to-gray-50 border border-gray-200 flex items-center justify-center mx-auto mb-6 shadow-sm"
          >
            <Icon className="h-10 w-10 text-gray-400" />
          </motion.div>
        )}
      </div>

      {/* Title */}
      <motion.h3
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.3, delay: 0.2 }}
        className="text-xl font-bold text-[#1C1C1C] mb-2"
      >
        {content.title}
      </motion.h3>

      {/* Subtitle */}
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 0.3, delay: 0.25 }}
        className="text-gray-600 text-base max-w-md"
      >
        {content.subtitle}
      </motion.p>

      {/* CTA Button */}
      {content.showCTA && onStartConversation && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.3 }}
          className="mt-8"
        >
          <Button
            onClick={onStartConversation}
            className="bg-gradient-to-r from-orange-500 to-orange-600 hover:from-orange-600 hover:to-orange-700 text-white rounded-xl px-8 h-12 text-base font-semibold shadow-lg shadow-orange-500/30 hover:shadow-xl hover:shadow-orange-500/40 hover:-translate-y-0.5 active:translate-y-0 transition-all duration-200 gap-2"
          >
            <MessageSquarePlus className="w-5 h-5" />
            Start a Conversation
          </Button>
        </motion.div>
      )}
    </motion.div>
  );
}
