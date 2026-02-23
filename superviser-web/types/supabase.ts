export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      activity_logs: {
        Row: {
          action: string
          action_category: string | null
          created_at: string | null
          description: string | null
          device_type: string | null
          id: string
          ip_address: unknown
          metadata: Json | null
          profile_id: string | null
          target_id: string | null
          target_type: string | null
          user_agent: string | null
        }
        Insert: {
          action: string
          action_category?: string | null
          created_at?: string | null
          description?: string | null
          device_type?: string | null
          id?: string
          ip_address?: unknown
          metadata?: Json | null
          profile_id?: string | null
          target_id?: string | null
          target_type?: string | null
          user_agent?: string | null
        }
        Update: {
          action?: string
          action_category?: string | null
          created_at?: string | null
          description?: string | null
          device_type?: string | null
          id?: string
          ip_address?: unknown
          metadata?: Json | null
          profile_id?: string | null
          target_id?: string | null
          target_type?: string | null
          user_agent?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "activity_logs_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      admins: {
        Row: {
          admin_role: string
          created_at: string | null
          id: string
          last_active_at: string | null
          permissions: Json | null
          profile_id: string
          updated_at: string | null
        }
        Insert: {
          admin_role: string
          created_at?: string | null
          id?: string
          last_active_at?: string | null
          permissions?: Json | null
          profile_id: string
          updated_at?: string | null
        }
        Update: {
          admin_role?: string
          created_at?: string | null
          id?: string
          last_active_at?: string | null
          permissions?: Json | null
          profile_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "admins_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      app_settings: {
        Row: {
          category: string | null
          created_at: string | null
          description: string | null
          id: string
          key: string
          updated_at: string | null
          value: Json
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          key: string
          updated_at?: string | null
          value: Json
        }
        Update: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          id?: string
          key?: string
          updated_at?: string | null
          value?: Json
        }
        Relationships: []
      }
      banners: {
        Row: {
          click_count: number | null
          created_at: string | null
          cta_action: string | null
          cta_text: string | null
          cta_url: string | null
          display_location: string
          display_order: number | null
          end_date: string | null
          id: string
          image_url: string
          image_url_mobile: string | null
          impression_count: number | null
          is_active: boolean | null
          start_date: string | null
          subtitle: string | null
          target_roles: string[] | null
          target_user_types: string[] | null
          title: string
          updated_at: string | null
        }
        Insert: {
          click_count?: number | null
          created_at?: string | null
          cta_action?: string | null
          cta_text?: string | null
          cta_url?: string | null
          display_location: string
          display_order?: number | null
          end_date?: string | null
          id?: string
          image_url: string
          image_url_mobile?: string | null
          impression_count?: number | null
          is_active?: boolean | null
          start_date?: string | null
          subtitle?: string | null
          target_roles?: string[] | null
          target_user_types?: string[] | null
          title: string
          updated_at?: string | null
        }
        Update: {
          click_count?: number | null
          created_at?: string | null
          cta_action?: string | null
          cta_text?: string | null
          cta_url?: string | null
          display_location?: string
          display_order?: number | null
          end_date?: string | null
          id?: string
          image_url?: string
          image_url_mobile?: string | null
          impression_count?: number | null
          is_active?: boolean | null
          start_date?: string | null
          subtitle?: string | null
          target_roles?: string[] | null
          target_user_types?: string[] | null
          title?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      chat_messages: {
        Row: {
          action_metadata: Json | null
          action_type: string | null
          chat_room_id: string
          contains_contact_info: boolean | null
          content: string | null
          created_at: string | null
          deleted_at: string | null
          edited_at: string | null
          file_name: string | null
          file_size_bytes: number | null
          file_type: string | null
          file_url: string | null
          flagged_reason: string | null
          id: string
          is_deleted: boolean | null
          is_edited: boolean | null
          is_flagged: boolean | null
          message_type: Database["public"]["Enums"]["message_type"]
          reply_to_id: string | null
          sender_id: string
        }
        Insert: {
          action_metadata?: Json | null
          action_type?: string | null
          chat_room_id: string
          contains_contact_info?: boolean | null
          content?: string | null
          created_at?: string | null
          deleted_at?: string | null
          edited_at?: string | null
          file_name?: string | null
          file_size_bytes?: number | null
          file_type?: string | null
          file_url?: string | null
          flagged_reason?: string | null
          id?: string
          is_deleted?: boolean | null
          is_edited?: boolean | null
          is_flagged?: boolean | null
          message_type?: Database["public"]["Enums"]["message_type"]
          reply_to_id?: string | null
          sender_id: string
        }
        Update: {
          action_metadata?: Json | null
          action_type?: string | null
          chat_room_id?: string
          contains_contact_info?: boolean | null
          content?: string | null
          created_at?: string | null
          deleted_at?: string | null
          edited_at?: string | null
          file_name?: string | null
          file_size_bytes?: number | null
          file_type?: string | null
          file_url?: string | null
          flagged_reason?: string | null
          id?: string
          is_deleted?: boolean | null
          is_edited?: boolean | null
          is_flagged?: boolean | null
          message_type?: Database["public"]["Enums"]["message_type"]
          reply_to_id?: string | null
          sender_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "chat_messages_chat_room_id_fkey"
            columns: ["chat_room_id"]
            isOneToOne: false
            referencedRelation: "chat_rooms"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "chat_messages_reply_to_id_fkey"
            columns: ["reply_to_id"]
            isOneToOne: false
            referencedRelation: "chat_messages"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "chat_messages_sender_id_fkey"
            columns: ["sender_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      chat_participants: {
        Row: {
          chat_room_id: string
          id: string
          is_active: boolean | null
          joined_at: string | null
          last_read_at: string | null
          left_at: string | null
          notifications_enabled: boolean | null
          participant_role: string
          profile_id: string
          unread_count: number | null
        }
        Insert: {
          chat_room_id: string
          id?: string
          is_active?: boolean | null
          joined_at?: string | null
          last_read_at?: string | null
          left_at?: string | null
          notifications_enabled?: boolean | null
          participant_role: string
          profile_id: string
          unread_count?: number | null
        }
        Update: {
          chat_room_id?: string
          id?: string
          is_active?: boolean | null
          joined_at?: string | null
          last_read_at?: string | null
          left_at?: string | null
          notifications_enabled?: boolean | null
          participant_role?: string
          profile_id?: string
          unread_count?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "chat_participants_chat_room_id_fkey"
            columns: ["chat_room_id"]
            isOneToOne: false
            referencedRelation: "chat_rooms"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "chat_participants_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      chat_rooms: {
        Row: {
          created_at: string | null
          id: string
          is_active: boolean | null
          is_suspended: boolean | null
          last_message_at: string | null
          message_count: number | null
          name: string | null
          project_id: string | null
          room_type: Database["public"]["Enums"]["chat_room_type"]
          suspended_at: string | null
          suspended_by: string | null
          suspension_reason: string | null
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          is_suspended?: boolean | null
          last_message_at?: string | null
          message_count?: number | null
          name?: string | null
          project_id?: string | null
          room_type: Database["public"]["Enums"]["chat_room_type"]
          suspended_at?: string | null
          suspended_by?: string | null
          suspension_reason?: string | null
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          is_suspended?: boolean | null
          last_message_at?: string | null
          message_count?: number | null
          name?: string | null
          project_id?: string | null
          room_type?: Database["public"]["Enums"]["chat_room_type"]
          suspended_at?: string | null
          suspended_by?: string | null
          suspension_reason?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "chat_rooms_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "chat_rooms_suspended_by_fkey"
            columns: ["suspended_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      courses: {
        Row: {
          created_at: string | null
          degree_type: string | null
          duration_years: number | null
          id: string
          is_active: boolean | null
          name: string
          short_name: string | null
        }
        Insert: {
          created_at?: string | null
          degree_type?: string | null
          duration_years?: number | null
          id?: string
          is_active?: boolean | null
          name: string
          short_name?: string | null
        }
        Update: {
          created_at?: string | null
          degree_type?: string | null
          duration_years?: number | null
          id?: string
          is_active?: boolean | null
          name?: string
          short_name?: string | null
        }
        Relationships: []
      }
      doer_activation: {
        Row: {
          activated_at: string | null
          bank_details_added: boolean | null
          bank_details_added_at: string | null
          created_at: string | null
          doer_id: string
          id: string
          is_fully_activated: boolean | null
          quiz_attempt_id: string | null
          quiz_passed: boolean | null
          quiz_passed_at: string | null
          total_quiz_attempts: number | null
          training_completed: boolean | null
          training_completed_at: string | null
          updated_at: string | null
        }
        Insert: {
          activated_at?: string | null
          bank_details_added?: boolean | null
          bank_details_added_at?: string | null
          created_at?: string | null
          doer_id: string
          id?: string
          is_fully_activated?: boolean | null
          quiz_attempt_id?: string | null
          quiz_passed?: boolean | null
          quiz_passed_at?: string | null
          total_quiz_attempts?: number | null
          training_completed?: boolean | null
          training_completed_at?: string | null
          updated_at?: string | null
        }
        Update: {
          activated_at?: string | null
          bank_details_added?: boolean | null
          bank_details_added_at?: string | null
          created_at?: string | null
          doer_id?: string
          id?: string
          is_fully_activated?: boolean | null
          quiz_attempt_id?: string | null
          quiz_passed?: boolean | null
          quiz_passed_at?: string | null
          total_quiz_attempts?: number | null
          training_completed?: boolean | null
          training_completed_at?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "doer_activation_doer_id_fkey"
            columns: ["doer_id"]
            isOneToOne: true
            referencedRelation: "doers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "doer_activation_quiz_attempt_id_fkey"
            columns: ["quiz_attempt_id"]
            isOneToOne: false
            referencedRelation: "quiz_attempts"
            referencedColumns: ["id"]
          },
        ]
      }
      doer_reviews: {
        Row: {
          communication_rating: number | null
          created_at: string | null
          doer_id: string
          flag_reason: string | null
          id: string
          is_flagged: boolean | null
          is_public: boolean | null
          overall_rating: number
          project_id: string | null
          quality_rating: number | null
          review_text: string | null
          reviewer_id: string
          reviewer_type: string
          timeliness_rating: number | null
          updated_at: string | null
        }
        Insert: {
          communication_rating?: number | null
          created_at?: string | null
          doer_id: string
          flag_reason?: string | null
          id?: string
          is_flagged?: boolean | null
          is_public?: boolean | null
          overall_rating: number
          project_id?: string | null
          quality_rating?: number | null
          review_text?: string | null
          reviewer_id: string
          reviewer_type: string
          timeliness_rating?: number | null
          updated_at?: string | null
        }
        Update: {
          communication_rating?: number | null
          created_at?: string | null
          doer_id?: string
          flag_reason?: string | null
          id?: string
          is_flagged?: boolean | null
          is_public?: boolean | null
          overall_rating?: number
          project_id?: string | null
          quality_rating?: number | null
          review_text?: string | null
          reviewer_id?: string
          reviewer_type?: string
          timeliness_rating?: number | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "doer_reviews_doer_id_fkey"
            columns: ["doer_id"]
            isOneToOne: false
            referencedRelation: "doers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "doer_reviews_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "doer_reviews_reviewer_id_fkey"
            columns: ["reviewer_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      doer_skills: {
        Row: {
          created_at: string | null
          doer_id: string
          id: string
          is_verified: boolean | null
          proficiency_level: string | null
          skill_id: string
          verified_at: string | null
          verified_by: string | null
        }
        Insert: {
          created_at?: string | null
          doer_id: string
          id?: string
          is_verified?: boolean | null
          proficiency_level?: string | null
          skill_id: string
          verified_at?: string | null
          verified_by?: string | null
        }
        Update: {
          created_at?: string | null
          doer_id?: string
          id?: string
          is_verified?: boolean | null
          proficiency_level?: string | null
          skill_id?: string
          verified_at?: string | null
          verified_by?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "doer_skills_doer_id_fkey"
            columns: ["doer_id"]
            isOneToOne: false
            referencedRelation: "doers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "doer_skills_skill_id_fkey"
            columns: ["skill_id"]
            isOneToOne: false
            referencedRelation: "skills"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "doer_skills_verified_by_fkey"
            columns: ["verified_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      doer_subjects: {
        Row: {
          created_at: string | null
          doer_id: string
          id: string
          is_primary: boolean | null
          subject_id: string
        }
        Insert: {
          created_at?: string | null
          doer_id: string
          id?: string
          is_primary?: boolean | null
          subject_id: string
        }
        Update: {
          created_at?: string | null
          doer_id?: string
          id?: string
          is_primary?: boolean | null
          subject_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "doer_subjects_doer_id_fkey"
            columns: ["doer_id"]
            isOneToOne: false
            referencedRelation: "doers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "doer_subjects_subject_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "subjects"
            referencedColumns: ["id"]
          },
        ]
      }
      doers: {
        Row: {
          activated_at: string | null
          availability_updated_at: string | null
          average_rating: number | null
          bank_account_name: string | null
          bank_account_number: string | null
          bank_ifsc_code: string | null
          bank_name: string | null
          bank_verified: boolean | null
          bio: string | null
          created_at: string | null
          experience_level: string
          flag_reason: string | null
          flagged_at: string | null
          flagged_by: string | null
          id: string
          is_activated: boolean | null
          is_available: boolean | null
          is_flagged: boolean | null
          max_concurrent_projects: number | null
          on_time_delivery_rate: number | null
          profile_id: string
          qualification: string
          success_rate: number | null
          total_earnings: number | null
          total_projects_completed: number | null
          total_reviews: number | null
          university_name: string | null
          updated_at: string | null
          upi_id: string | null
          years_of_experience: number | null
        }
        Insert: {
          activated_at?: string | null
          availability_updated_at?: string | null
          average_rating?: number | null
          bank_account_name?: string | null
          bank_account_number?: string | null
          bank_ifsc_code?: string | null
          bank_name?: string | null
          bank_verified?: boolean | null
          bio?: string | null
          created_at?: string | null
          experience_level: string
          flag_reason?: string | null
          flagged_at?: string | null
          flagged_by?: string | null
          id?: string
          is_activated?: boolean | null
          is_available?: boolean | null
          is_flagged?: boolean | null
          max_concurrent_projects?: number | null
          on_time_delivery_rate?: number | null
          profile_id: string
          qualification: string
          success_rate?: number | null
          total_earnings?: number | null
          total_projects_completed?: number | null
          total_reviews?: number | null
          university_name?: string | null
          updated_at?: string | null
          upi_id?: string | null
          years_of_experience?: number | null
        }
        Update: {
          activated_at?: string | null
          availability_updated_at?: string | null
          average_rating?: number | null
          bank_account_name?: string | null
          bank_account_number?: string | null
          bank_ifsc_code?: string | null
          bank_name?: string | null
          bank_verified?: boolean | null
          bio?: string | null
          created_at?: string | null
          experience_level?: string
          flag_reason?: string | null
          flagged_at?: string | null
          flagged_by?: string | null
          id?: string
          is_activated?: boolean | null
          is_available?: boolean | null
          is_flagged?: boolean | null
          max_concurrent_projects?: number | null
          on_time_delivery_rate?: number | null
          profile_id?: string
          qualification?: string
          success_rate?: number | null
          total_earnings?: number | null
          total_projects_completed?: number | null
          total_reviews?: number | null
          university_name?: string | null
          updated_at?: string | null
          upi_id?: string | null
          years_of_experience?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "doers_flagged_by_fkey"
            columns: ["flagged_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "doers_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      error_logs: {
        Row: {
          app_version: string | null
          created_at: string | null
          device_info: Json | null
          error_message: string
          error_type: string
          id: string
          is_resolved: boolean | null
          platform: string | null
          profile_id: string | null
          request_body: Json | null
          request_method: string | null
          request_url: string | null
          resolution_notes: string | null
          resolved_at: string | null
          sentry_event_id: string | null
          stack_trace: string | null
        }
        Insert: {
          app_version?: string | null
          created_at?: string | null
          device_info?: Json | null
          error_message: string
          error_type: string
          id?: string
          is_resolved?: boolean | null
          platform?: string | null
          profile_id?: string | null
          request_body?: Json | null
          request_method?: string | null
          request_url?: string | null
          resolution_notes?: string | null
          resolved_at?: string | null
          sentry_event_id?: string | null
          stack_trace?: string | null
        }
        Update: {
          app_version?: string | null
          created_at?: string | null
          device_info?: Json | null
          error_message?: string
          error_type?: string
          id?: string
          is_resolved?: boolean | null
          platform?: string | null
          profile_id?: string | null
          request_body?: Json | null
          request_method?: string | null
          request_url?: string | null
          resolution_notes?: string | null
          resolved_at?: string | null
          sentry_event_id?: string | null
          stack_trace?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "error_logs_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      faqs: {
        Row: {
          answer: string
          category: string | null
          created_at: string | null
          display_order: number | null
          helpful_count: number | null
          id: string
          is_active: boolean | null
          not_helpful_count: number | null
          question: string
          target_role: string | null
          updated_at: string | null
        }
        Insert: {
          answer: string
          category?: string | null
          created_at?: string | null
          display_order?: number | null
          helpful_count?: number | null
          id?: string
          is_active?: boolean | null
          not_helpful_count?: number | null
          question: string
          target_role?: string | null
          updated_at?: string | null
        }
        Update: {
          answer?: string
          category?: string | null
          created_at?: string | null
          display_order?: number | null
          helpful_count?: number | null
          id?: string
          is_active?: boolean | null
          not_helpful_count?: number | null
          question?: string
          target_role?: string | null
          updated_at?: string | null
        }
        Relationships: []
      }
      industries: {
        Row: {
          created_at: string | null
          id: string
          is_active: boolean | null
          name: string
          slug: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          slug: string
        }
        Update: {
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          slug?: string
        }
        Relationships: []
      }
      invoices: {
        Row: {
          created_at: string | null
          discount_amount: number | null
          due_date: string | null
          id: string
          invoice_date: string
          invoice_number: string
          payment_id: string | null
          pdf_url: string | null
          project_id: string | null
          status: string | null
          subtotal: number
          tax_amount: number | null
          tax_rate: number | null
          tax_type: string | null
          total_amount: number
          user_id: string
        }
        Insert: {
          created_at?: string | null
          discount_amount?: number | null
          due_date?: string | null
          id?: string
          invoice_date?: string
          invoice_number: string
          payment_id?: string | null
          pdf_url?: string | null
          project_id?: string | null
          status?: string | null
          subtotal: number
          tax_amount?: number | null
          tax_rate?: number | null
          tax_type?: string | null
          total_amount: number
          user_id: string
        }
        Update: {
          created_at?: string | null
          discount_amount?: number | null
          due_date?: string | null
          id?: string
          invoice_date?: string
          invoice_number?: string
          payment_id?: string | null
          pdf_url?: string | null
          project_id?: string | null
          status?: string | null
          subtotal?: number
          tax_amount?: number | null
          tax_rate?: number | null
          tax_type?: string | null
          total_amount?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "invoices_payment_id_fkey"
            columns: ["payment_id"]
            isOneToOne: false
            referencedRelation: "payments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "invoices_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "invoices_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      listing_images: {
        Row: {
          created_at: string | null
          display_order: number | null
          id: string
          image_url: string
          is_primary: boolean | null
          listing_id: string
          thumbnail_url: string | null
        }
        Insert: {
          created_at?: string | null
          display_order?: number | null
          id?: string
          image_url: string
          is_primary?: boolean | null
          listing_id: string
          thumbnail_url?: string | null
        }
        Update: {
          created_at?: string | null
          display_order?: number | null
          id?: string
          image_url?: string
          is_primary?: boolean | null
          listing_id?: string
          thumbnail_url?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "listing_images_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: false
            referencedRelation: "marketplace_listings"
            referencedColumns: ["id"]
          },
        ]
      }
      listing_inquiries: {
        Row: {
          created_at: string | null
          id: string
          inquirer_id: string
          listing_id: string
          message: string | null
          responded_at: string | null
          response: string | null
          status: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          inquirer_id: string
          listing_id: string
          message?: string | null
          responded_at?: string | null
          response?: string | null
          status?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          inquirer_id?: string
          listing_id?: string
          message?: string | null
          responded_at?: string | null
          response?: string | null
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "listing_inquiries_inquirer_id_fkey"
            columns: ["inquirer_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "listing_inquiries_listing_id_fkey"
            columns: ["listing_id"]
            isOneToOne: false
            referencedRelation: "marketplace_listings"
            referencedColumns: ["id"]
          },
        ]
      }
      marketplace_categories: {
        Row: {
          created_at: string | null
          description: string | null
          display_order: number | null
          icon: string | null
          id: string
          is_active: boolean | null
          name: string
          parent_id: string | null
          slug: string
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          display_order?: number | null
          icon?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          parent_id?: string | null
          slug: string
        }
        Update: {
          created_at?: string | null
          description?: string | null
          display_order?: number | null
          icon?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          parent_id?: string | null
          slug?: string
        }
        Relationships: [
          {
            foreignKeyName: "marketplace_categories_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "marketplace_categories"
            referencedColumns: ["id"]
          },
        ]
      }
      marketplace_listings: {
        Row: {
          application_deadline: string | null
          available_from: string | null
          bedrooms: number | null
          category_id: string | null
          city: string | null
          company_name: string | null
          created_at: string | null
          description: string | null
          distance_km: number | null
          expires_at: string | null
          housing_type: string | null
          id: string
          inquiry_count: number | null
          item_condition: string | null
          latitude: number | null
          listing_type: Database["public"]["Enums"]["listing_type"]
          location_text: string | null
          longitude: number | null
          opportunity_type: string | null
          opportunity_url: string | null
          poll_ends_at: string | null
          poll_options: Json | null
          post_content: string | null
          price: number | null
          price_negotiable: boolean | null
          rejection_reason: string | null
          rent_period: string | null
          reviewed_at: string | null
          reviewed_by: string | null
          seller_id: string
          status: Database["public"]["Enums"]["listing_status"]
          title: string
          university_id: string | null
          updated_at: string | null
          view_count: number | null
        }
        Insert: {
          application_deadline?: string | null
          available_from?: string | null
          bedrooms?: number | null
          category_id?: string | null
          city?: string | null
          company_name?: string | null
          created_at?: string | null
          description?: string | null
          distance_km?: number | null
          expires_at?: string | null
          housing_type?: string | null
          id?: string
          inquiry_count?: number | null
          item_condition?: string | null
          latitude?: number | null
          listing_type: Database["public"]["Enums"]["listing_type"]
          location_text?: string | null
          longitude?: number | null
          opportunity_type?: string | null
          opportunity_url?: string | null
          poll_ends_at?: string | null
          poll_options?: Json | null
          post_content?: string | null
          price?: number | null
          price_negotiable?: boolean | null
          rejection_reason?: string | null
          rent_period?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          seller_id: string
          status?: Database["public"]["Enums"]["listing_status"]
          title: string
          university_id?: string | null
          updated_at?: string | null
          view_count?: number | null
        }
        Update: {
          application_deadline?: string | null
          available_from?: string | null
          bedrooms?: number | null
          category_id?: string | null
          city?: string | null
          company_name?: string | null
          created_at?: string | null
          description?: string | null
          distance_km?: number | null
          expires_at?: string | null
          housing_type?: string | null
          id?: string
          inquiry_count?: number | null
          item_condition?: string | null
          latitude?: number | null
          listing_type?: Database["public"]["Enums"]["listing_type"]
          location_text?: string | null
          longitude?: number | null
          opportunity_type?: string | null
          opportunity_url?: string | null
          poll_ends_at?: string | null
          poll_options?: Json | null
          post_content?: string | null
          price?: number | null
          price_negotiable?: boolean | null
          rejection_reason?: string | null
          rent_period?: string | null
          reviewed_at?: string | null
          reviewed_by?: string | null
          seller_id?: string
          status?: Database["public"]["Enums"]["listing_status"]
          title?: string
          university_id?: string | null
          updated_at?: string | null
          view_count?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "marketplace_listings_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "marketplace_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "marketplace_listings_reviewed_by_fkey"
            columns: ["reviewed_by"]
            isOneToOne: false
            referencedRelation: "admins"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "marketplace_listings_seller_id_fkey"
            columns: ["seller_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "marketplace_listings_university_id_fkey"
            columns: ["university_id"]
            isOneToOne: false
            referencedRelation: "universities"
            referencedColumns: ["id"]
          },
        ]
      }
      notifications: {
        Row: {
          action_url: string | null
          body: string
          created_at: string | null
          email_sent: boolean | null
          email_sent_at: string | null
          id: string
          is_read: boolean | null
          notification_type: Database["public"]["Enums"]["notification_type"]
          profile_id: string
          push_sent: boolean | null
          push_sent_at: string | null
          read_at: string | null
          reference_id: string | null
          reference_type: string | null
          title: string
          whatsapp_sent: boolean | null
          whatsapp_sent_at: string | null
        }
        Insert: {
          action_url?: string | null
          body: string
          created_at?: string | null
          email_sent?: boolean | null
          email_sent_at?: string | null
          id?: string
          is_read?: boolean | null
          notification_type: Database["public"]["Enums"]["notification_type"]
          profile_id: string
          push_sent?: boolean | null
          push_sent_at?: string | null
          read_at?: string | null
          reference_id?: string | null
          reference_type?: string | null
          title: string
          whatsapp_sent?: boolean | null
          whatsapp_sent_at?: string | null
        }
        Update: {
          action_url?: string | null
          body?: string
          created_at?: string | null
          email_sent?: boolean | null
          email_sent_at?: string | null
          id?: string
          is_read?: boolean | null
          notification_type?: Database["public"]["Enums"]["notification_type"]
          profile_id?: string
          push_sent?: boolean | null
          push_sent_at?: string | null
          read_at?: string | null
          reference_id?: string | null
          reference_type?: string | null
          title?: string
          whatsapp_sent?: boolean | null
          whatsapp_sent_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "notifications_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      payment_methods: {
        Row: {
          bank_name: string | null
          card_last_four: string | null
          card_network: string | null
          card_token: string | null
          card_type: string | null
          created_at: string | null
          display_name: string | null
          id: string
          is_default: boolean | null
          is_verified: boolean | null
          method_type: string
          profile_id: string
          updated_at: string | null
          upi_id: string | null
        }
        Insert: {
          bank_name?: string | null
          card_last_four?: string | null
          card_network?: string | null
          card_token?: string | null
          card_type?: string | null
          created_at?: string | null
          display_name?: string | null
          id?: string
          is_default?: boolean | null
          is_verified?: boolean | null
          method_type: string
          profile_id: string
          updated_at?: string | null
          upi_id?: string | null
        }
        Update: {
          bank_name?: string | null
          card_last_four?: string | null
          card_network?: string | null
          card_token?: string | null
          card_type?: string | null
          created_at?: string | null
          display_name?: string | null
          id?: string
          is_default?: boolean | null
          is_verified?: boolean | null
          method_type?: string
          profile_id?: string
          updated_at?: string | null
          upi_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "payment_methods_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      payments: {
        Row: {
          amount: number
          completed_at: string | null
          created_at: string | null
          currency: string | null
          failure_code: string | null
          failure_reason: string | null
          gateway: string | null
          gateway_order_id: string | null
          gateway_payment_id: string | null
          gateway_signature: string | null
          id: string
          initiated_at: string | null
          payment_method: string | null
          payment_method_details: Json | null
          reference_id: string | null
          reference_type: string
          refund_amount: number | null
          refund_id: string | null
          refund_reason: string | null
          refunded_at: string | null
          status: Database["public"]["Enums"]["payment_status"]
          updated_at: string | null
          user_id: string
        }
        Insert: {
          amount: number
          completed_at?: string | null
          created_at?: string | null
          currency?: string | null
          failure_code?: string | null
          failure_reason?: string | null
          gateway?: string | null
          gateway_order_id?: string | null
          gateway_payment_id?: string | null
          gateway_signature?: string | null
          id?: string
          initiated_at?: string | null
          payment_method?: string | null
          payment_method_details?: Json | null
          reference_id?: string | null
          reference_type: string
          refund_amount?: number | null
          refund_id?: string | null
          refund_reason?: string | null
          refunded_at?: string | null
          status?: Database["public"]["Enums"]["payment_status"]
          updated_at?: string | null
          user_id: string
        }
        Update: {
          amount?: number
          completed_at?: string | null
          created_at?: string | null
          currency?: string | null
          failure_code?: string | null
          failure_reason?: string | null
          gateway?: string | null
          gateway_order_id?: string | null
          gateway_payment_id?: string | null
          gateway_signature?: string | null
          id?: string
          initiated_at?: string | null
          payment_method?: string | null
          payment_method_details?: Json | null
          reference_id?: string | null
          reference_type?: string
          refund_amount?: number | null
          refund_id?: string | null
          refund_reason?: string | null
          refunded_at?: string | null
          status?: Database["public"]["Enums"]["payment_status"]
          updated_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "payments_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      payout_requests: {
        Row: {
          approved_amount: number | null
          created_at: string | null
          id: string
          payout_id: string | null
          profile_id: string
          rejection_reason: string | null
          requested_amount: number
          requester_type: string
          reviewed_at: string | null
          reviewed_by: string | null
          status: string | null
          updated_at: string | null
        }
        Insert: {
          approved_amount?: number | null
          created_at?: string | null
          id?: string
          payout_id?: string | null
          profile_id: string
          rejection_reason?: string | null
          requested_amount: number
          requester_type: string
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Update: {
          approved_amount?: number | null
          created_at?: string | null
          id?: string
          payout_id?: string | null
          profile_id?: string
          rejection_reason?: string | null
          requested_amount?: number
          requester_type?: string
          reviewed_at?: string | null
          reviewed_by?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "payout_requests_payout_id_fkey"
            columns: ["payout_id"]
            isOneToOne: false
            referencedRelation: "payouts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payout_requests_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payout_requests_reviewed_by_fkey"
            columns: ["reviewed_by"]
            isOneToOne: false
            referencedRelation: "admins"
            referencedColumns: ["id"]
          },
        ]
      }
      payouts: {
        Row: {
          amount: number
          bank_account_name: string | null
          bank_account_number: string | null
          bank_ifsc_code: string | null
          bank_name: string | null
          completed_at: string | null
          created_at: string | null
          currency: string | null
          failure_reason: string | null
          gateway: string | null
          gateway_payout_id: string | null
          gateway_reference: string | null
          id: string
          payout_method: string
          processed_at: string | null
          recipient_id: string
          recipient_type: string
          reference_ids: string[] | null
          reference_type: string | null
          requested_at: string | null
          retry_count: number | null
          status: Database["public"]["Enums"]["payout_status"]
          updated_at: string | null
          upi_id: string | null
        }
        Insert: {
          amount: number
          bank_account_name?: string | null
          bank_account_number?: string | null
          bank_ifsc_code?: string | null
          bank_name?: string | null
          completed_at?: string | null
          created_at?: string | null
          currency?: string | null
          failure_reason?: string | null
          gateway?: string | null
          gateway_payout_id?: string | null
          gateway_reference?: string | null
          id?: string
          payout_method: string
          processed_at?: string | null
          recipient_id: string
          recipient_type: string
          reference_ids?: string[] | null
          reference_type?: string | null
          requested_at?: string | null
          retry_count?: number | null
          status?: Database["public"]["Enums"]["payout_status"]
          updated_at?: string | null
          upi_id?: string | null
        }
        Update: {
          amount?: number
          bank_account_name?: string | null
          bank_account_number?: string | null
          bank_ifsc_code?: string | null
          bank_name?: string | null
          completed_at?: string | null
          created_at?: string | null
          currency?: string | null
          failure_reason?: string | null
          gateway?: string | null
          gateway_payout_id?: string | null
          gateway_reference?: string | null
          id?: string
          payout_method?: string
          processed_at?: string | null
          recipient_id?: string
          recipient_type?: string
          reference_ids?: string[] | null
          reference_type?: string | null
          requested_at?: string | null
          retry_count?: number | null
          status?: Database["public"]["Enums"]["payout_status"]
          updated_at?: string | null
          upi_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "payouts_recipient_id_fkey"
            columns: ["recipient_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      pricing_guides: {
        Row: {
          base_price_fixed: number | null
          base_price_per_page: number | null
          base_price_per_word: number | null
          complexity_easy_multiplier: number | null
          complexity_hard_multiplier: number | null
          complexity_medium_multiplier: number | null
          created_at: string | null
          id: string
          is_active: boolean | null
          platform_percentage: number | null
          service_type: Database["public"]["Enums"]["service_type"]
          subject_id: string | null
          supervisor_percentage: number | null
          updated_at: string | null
          urgency_24h_multiplier: number | null
          urgency_48h_multiplier: number | null
          urgency_72h_multiplier: number | null
        }
        Insert: {
          base_price_fixed?: number | null
          base_price_per_page?: number | null
          base_price_per_word?: number | null
          complexity_easy_multiplier?: number | null
          complexity_hard_multiplier?: number | null
          complexity_medium_multiplier?: number | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          platform_percentage?: number | null
          service_type: Database["public"]["Enums"]["service_type"]
          subject_id?: string | null
          supervisor_percentage?: number | null
          updated_at?: string | null
          urgency_24h_multiplier?: number | null
          urgency_48h_multiplier?: number | null
          urgency_72h_multiplier?: number | null
        }
        Update: {
          base_price_fixed?: number | null
          base_price_per_page?: number | null
          base_price_per_word?: number | null
          complexity_easy_multiplier?: number | null
          complexity_hard_multiplier?: number | null
          complexity_medium_multiplier?: number | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          platform_percentage?: number | null
          service_type?: Database["public"]["Enums"]["service_type"]
          subject_id?: string | null
          supervisor_percentage?: number | null
          updated_at?: string | null
          urgency_24h_multiplier?: number | null
          urgency_48h_multiplier?: number | null
          urgency_72h_multiplier?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "pricing_guides_subject_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "subjects"
            referencedColumns: ["id"]
          },
        ]
      }
      professionals: {
        Row: {
          business_type: string | null
          company_name: string | null
          created_at: string | null
          gst_number: string | null
          id: string
          industry_id: string | null
          job_title: string | null
          linkedin_url: string | null
          professional_type: string
          profile_id: string
          updated_at: string | null
        }
        Insert: {
          business_type?: string | null
          company_name?: string | null
          created_at?: string | null
          gst_number?: string | null
          id?: string
          industry_id?: string | null
          job_title?: string | null
          linkedin_url?: string | null
          professional_type: string
          profile_id: string
          updated_at?: string | null
        }
        Update: {
          business_type?: string | null
          company_name?: string | null
          created_at?: string | null
          gst_number?: string | null
          id?: string
          industry_id?: string | null
          job_title?: string | null
          linkedin_url?: string | null
          professional_type?: string
          profile_id?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "professionals_industry_id_fkey"
            columns: ["industry_id"]
            isOneToOne: false
            referencedRelation: "industries"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "professionals_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          avatar_url: string | null
          block_reason: string | null
          city: string | null
          country: string | null
          created_at: string | null
          deleted_at: string | null
          device_tokens: string[] | null
          email: string
          full_name: string
          id: string
          is_active: boolean | null
          is_blocked: boolean | null
          last_login_at: string | null
          login_count: number | null
          phone: string | null
          phone_verified: boolean | null
          state: string | null
          updated_at: string | null
          user_type: string
        }
        Insert: {
          avatar_url?: string | null
          block_reason?: string | null
          city?: string | null
          country?: string | null
          created_at?: string | null
          deleted_at?: string | null
          device_tokens?: string[] | null
          email: string
          full_name: string
          id: string
          is_active?: boolean | null
          is_blocked?: boolean | null
          last_login_at?: string | null
          login_count?: number | null
          phone?: string | null
          phone_verified?: boolean | null
          state?: string | null
          updated_at?: string | null
          user_type: string
        }
        Update: {
          avatar_url?: string | null
          block_reason?: string | null
          city?: string | null
          country?: string | null
          created_at?: string | null
          deleted_at?: string | null
          device_tokens?: string[] | null
          email?: string
          full_name?: string
          id?: string
          is_active?: boolean | null
          is_blocked?: boolean | null
          last_login_at?: string | null
          login_count?: number | null
          phone?: string | null
          phone_verified?: boolean | null
          state?: string | null
          updated_at?: string | null
          user_type?: string
        }
        Relationships: []
      }
      project_assignments: {
        Row: {
          assigned_at: string | null
          assigned_by: string
          assignee_id: string
          assignment_type: string
          ended_at: string | null
          id: string
          project_id: string
          reassignment_reason: string | null
          status: string | null
        }
        Insert: {
          assigned_at?: string | null
          assigned_by: string
          assignee_id: string
          assignment_type: string
          ended_at?: string | null
          id?: string
          project_id: string
          reassignment_reason?: string | null
          status?: string | null
        }
        Update: {
          assigned_at?: string | null
          assigned_by?: string
          assignee_id?: string
          assignment_type?: string
          ended_at?: string | null
          id?: string
          project_id?: string
          reassignment_reason?: string | null
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "project_assignments_assigned_by_fkey"
            columns: ["assigned_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "project_assignments_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      project_deliverables: {
        Row: {
          created_at: string | null
          file_name: string
          file_size_bytes: number | null
          file_type: string | null
          file_url: string
          id: string
          is_final: boolean | null
          project_id: string
          qc_at: string | null
          qc_by: string | null
          qc_notes: string | null
          qc_status: string | null
          uploaded_by: string
          version: number | null
        }
        Insert: {
          created_at?: string | null
          file_name: string
          file_size_bytes?: number | null
          file_type?: string | null
          file_url: string
          id?: string
          is_final?: boolean | null
          project_id: string
          qc_at?: string | null
          qc_by?: string | null
          qc_notes?: string | null
          qc_status?: string | null
          uploaded_by: string
          version?: number | null
        }
        Update: {
          created_at?: string | null
          file_name?: string
          file_size_bytes?: number | null
          file_type?: string | null
          file_url?: string
          id?: string
          is_final?: boolean | null
          project_id?: string
          qc_at?: string | null
          qc_by?: string | null
          qc_notes?: string | null
          qc_status?: string | null
          uploaded_by?: string
          version?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "project_deliverables_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "project_deliverables_qc_by_fkey"
            columns: ["qc_by"]
            isOneToOne: false
            referencedRelation: "supervisors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "project_deliverables_uploaded_by_fkey"
            columns: ["uploaded_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      project_files: {
        Row: {
          created_at: string | null
          file_category: string | null
          file_name: string
          file_size_bytes: number | null
          file_type: string | null
          file_url: string
          id: string
          project_id: string
          uploaded_by: string
        }
        Insert: {
          created_at?: string | null
          file_category?: string | null
          file_name: string
          file_size_bytes?: number | null
          file_type?: string | null
          file_url: string
          id?: string
          project_id: string
          uploaded_by: string
        }
        Update: {
          created_at?: string | null
          file_category?: string | null
          file_name?: string
          file_size_bytes?: number | null
          file_type?: string | null
          file_url?: string
          id?: string
          project_id?: string
          uploaded_by?: string
        }
        Relationships: [
          {
            foreignKeyName: "project_files_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "project_files_uploaded_by_fkey"
            columns: ["uploaded_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      project_quotes: {
        Row: {
          base_price: number | null
          complexity_fee: number | null
          created_at: string | null
          discount_amount: number | null
          discount_code: string | null
          doer_amount: number
          id: string
          platform_amount: number
          project_id: string
          quoted_by: string
          rejection_reason: string | null
          responded_at: string | null
          status: string | null
          supervisor_amount: number
          updated_at: string | null
          urgency_fee: number | null
          user_amount: number
          valid_until: string | null
        }
        Insert: {
          base_price?: number | null
          complexity_fee?: number | null
          created_at?: string | null
          discount_amount?: number | null
          discount_code?: string | null
          doer_amount: number
          id?: string
          platform_amount: number
          project_id: string
          quoted_by: string
          rejection_reason?: string | null
          responded_at?: string | null
          status?: string | null
          supervisor_amount: number
          updated_at?: string | null
          urgency_fee?: number | null
          user_amount: number
          valid_until?: string | null
        }
        Update: {
          base_price?: number | null
          complexity_fee?: number | null
          created_at?: string | null
          discount_amount?: number | null
          discount_code?: string | null
          doer_amount?: number
          id?: string
          platform_amount?: number
          project_id?: string
          quoted_by?: string
          rejection_reason?: string | null
          responded_at?: string | null
          status?: string | null
          supervisor_amount?: number
          updated_at?: string | null
          urgency_fee?: number | null
          user_amount?: number
          valid_until?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "project_quotes_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "project_quotes_quoted_by_fkey"
            columns: ["quoted_by"]
            isOneToOne: false
            referencedRelation: "supervisors"
            referencedColumns: ["id"]
          },
        ]
      }
      project_revisions: {
        Row: {
          completed_at: string | null
          created_at: string | null
          feedback: string
          id: string
          project_id: string
          requested_by: string
          requested_by_type: string
          response_notes: string | null
          revision_number: number
          specific_changes: string | null
          status: string | null
          updated_at: string | null
        }
        Insert: {
          completed_at?: string | null
          created_at?: string | null
          feedback: string
          id?: string
          project_id: string
          requested_by: string
          requested_by_type: string
          response_notes?: string | null
          revision_number: number
          specific_changes?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Update: {
          completed_at?: string | null
          created_at?: string | null
          feedback?: string
          id?: string
          project_id?: string
          requested_by?: string
          requested_by_type?: string
          response_notes?: string | null
          revision_number?: number
          specific_changes?: string | null
          status?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "project_revisions_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "project_revisions_requested_by_fkey"
            columns: ["requested_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      project_status_history: {
        Row: {
          changed_by: string | null
          changed_by_type: string | null
          created_at: string | null
          from_status: Database["public"]["Enums"]["project_status"] | null
          id: string
          metadata: Json | null
          notes: string | null
          project_id: string
          to_status: Database["public"]["Enums"]["project_status"]
        }
        Insert: {
          changed_by?: string | null
          changed_by_type?: string | null
          created_at?: string | null
          from_status?: Database["public"]["Enums"]["project_status"] | null
          id?: string
          metadata?: Json | null
          notes?: string | null
          project_id: string
          to_status: Database["public"]["Enums"]["project_status"]
        }
        Update: {
          changed_by?: string | null
          changed_by_type?: string | null
          created_at?: string | null
          from_status?: Database["public"]["Enums"]["project_status"] | null
          id?: string
          metadata?: Json | null
          notes?: string | null
          project_id?: string
          to_status?: Database["public"]["Enums"]["project_status"]
        }
        Relationships: [
          {
            foreignKeyName: "project_status_history_changed_by_fkey"
            columns: ["changed_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "project_status_history_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      project_timeline: {
        Row: {
          completed_at: string | null
          created_at: string | null
          description: string | null
          expected_at: string | null
          id: string
          is_completed: boolean | null
          milestone_title: string
          milestone_type: string
          project_id: string
          sequence_order: number
        }
        Insert: {
          completed_at?: string | null
          created_at?: string | null
          description?: string | null
          expected_at?: string | null
          id?: string
          is_completed?: boolean | null
          milestone_title: string
          milestone_type: string
          project_id: string
          sequence_order: number
        }
        Update: {
          completed_at?: string | null
          created_at?: string | null
          description?: string | null
          expected_at?: string | null
          id?: string
          is_completed?: boolean | null
          milestone_title?: string
          milestone_type?: string
          project_id?: string
          sequence_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "project_timeline_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      projects: {
        Row: {
          ai_report_url: string | null
          ai_score: number | null
          auto_approve_at: string | null
          cancellation_reason: string | null
          cancelled_at: string | null
          cancelled_by: string | null
          completed_at: string | null
          completion_notes: string | null
          created_at: string | null
          deadline: string
          deadline_extended: boolean | null
          deadline_extension_reason: string | null
          delivered_at: string | null
          description: string | null
          doer_assigned_at: string | null
          doer_id: string | null
          doer_payout: number | null
          expected_delivery_at: string | null
          focus_areas: string[] | null
          id: string
          is_paid: boolean | null
          live_document_url: string | null
          original_deadline: string | null
          page_count: number | null
          paid_at: string | null
          payment_id: string | null
          plagiarism_report_url: string | null
          plagiarism_score: number | null
          platform_fee: number | null
          progress_percentage: number | null
          project_number: string
          reference_style_id: string | null
          service_type: Database["public"]["Enums"]["service_type"]
          source: string | null
          specific_instructions: string | null
          status: Database["public"]["Enums"]["project_status"]
          status_updated_at: string | null
          subject_id: string | null
          supervisor_assigned_at: string | null
          supervisor_commission: number | null
          supervisor_id: string | null
          title: string
          topic: string | null
          updated_at: string | null
          user_approved: boolean | null
          user_approved_at: string | null
          user_feedback: string | null
          user_grade: string | null
          user_id: string
          user_quote: number | null
          word_count: number | null
        }
        Insert: {
          ai_report_url?: string | null
          ai_score?: number | null
          auto_approve_at?: string | null
          cancellation_reason?: string | null
          cancelled_at?: string | null
          cancelled_by?: string | null
          completed_at?: string | null
          completion_notes?: string | null
          created_at?: string | null
          deadline: string
          deadline_extended?: boolean | null
          deadline_extension_reason?: string | null
          delivered_at?: string | null
          description?: string | null
          doer_assigned_at?: string | null
          doer_id?: string | null
          doer_payout?: number | null
          expected_delivery_at?: string | null
          focus_areas?: string[] | null
          id?: string
          is_paid?: boolean | null
          live_document_url?: string | null
          original_deadline?: string | null
          page_count?: number | null
          paid_at?: string | null
          payment_id?: string | null
          plagiarism_report_url?: string | null
          plagiarism_score?: number | null
          platform_fee?: number | null
          progress_percentage?: number | null
          project_number: string
          reference_style_id?: string | null
          service_type: Database["public"]["Enums"]["service_type"]
          source?: string | null
          specific_instructions?: string | null
          status?: Database["public"]["Enums"]["project_status"]
          status_updated_at?: string | null
          subject_id?: string | null
          supervisor_assigned_at?: string | null
          supervisor_commission?: number | null
          supervisor_id?: string | null
          title: string
          topic?: string | null
          updated_at?: string | null
          user_approved?: boolean | null
          user_approved_at?: string | null
          user_feedback?: string | null
          user_grade?: string | null
          user_id: string
          user_quote?: number | null
          word_count?: number | null
        }
        Update: {
          ai_report_url?: string | null
          ai_score?: number | null
          auto_approve_at?: string | null
          cancellation_reason?: string | null
          cancelled_at?: string | null
          cancelled_by?: string | null
          completed_at?: string | null
          completion_notes?: string | null
          created_at?: string | null
          deadline?: string
          deadline_extended?: boolean | null
          deadline_extension_reason?: string | null
          delivered_at?: string | null
          description?: string | null
          doer_assigned_at?: string | null
          doer_id?: string | null
          doer_payout?: number | null
          expected_delivery_at?: string | null
          focus_areas?: string[] | null
          id?: string
          is_paid?: boolean | null
          live_document_url?: string | null
          original_deadline?: string | null
          page_count?: number | null
          paid_at?: string | null
          payment_id?: string | null
          plagiarism_report_url?: string | null
          plagiarism_score?: number | null
          platform_fee?: number | null
          progress_percentage?: number | null
          project_number?: string
          reference_style_id?: string | null
          service_type?: Database["public"]["Enums"]["service_type"]
          source?: string | null
          specific_instructions?: string | null
          status?: Database["public"]["Enums"]["project_status"]
          status_updated_at?: string | null
          subject_id?: string | null
          supervisor_assigned_at?: string | null
          supervisor_commission?: number | null
          supervisor_id?: string | null
          title?: string
          topic?: string | null
          updated_at?: string | null
          user_approved?: boolean | null
          user_approved_at?: string | null
          user_feedback?: string | null
          user_grade?: string | null
          user_id?: string
          user_quote?: number | null
          word_count?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "projects_cancelled_by_fkey"
            columns: ["cancelled_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projects_doer_id_fkey"
            columns: ["doer_id"]
            isOneToOne: false
            referencedRelation: "doers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projects_payment_id_fkey"
            columns: ["payment_id"]
            isOneToOne: false
            referencedRelation: "payments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projects_reference_style_id_fkey"
            columns: ["reference_style_id"]
            isOneToOne: false
            referencedRelation: "reference_styles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projects_subject_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "subjects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projects_supervisor_id_fkey"
            columns: ["supervisor_id"]
            isOneToOne: false
            referencedRelation: "supervisors"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "projects_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      quality_reports: {
        Row: {
          created_at: string | null
          deliverable_id: string | null
          details: Json | null
          generated_by: string | null
          id: string
          project_id: string
          report_type: string
          report_url: string | null
          result: string | null
          score: number | null
          tool_used: string | null
        }
        Insert: {
          created_at?: string | null
          deliverable_id?: string | null
          details?: Json | null
          generated_by?: string | null
          id?: string
          project_id: string
          report_type: string
          report_url?: string | null
          result?: string | null
          score?: number | null
          tool_used?: string | null
        }
        Update: {
          created_at?: string | null
          deliverable_id?: string | null
          details?: Json | null
          generated_by?: string | null
          id?: string
          project_id?: string
          report_type?: string
          report_url?: string | null
          result?: string | null
          score?: number | null
          tool_used?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "quality_reports_deliverable_id_fkey"
            columns: ["deliverable_id"]
            isOneToOne: false
            referencedRelation: "project_deliverables"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quality_reports_generated_by_fkey"
            columns: ["generated_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "quality_reports_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
        ]
      }
      quiz_attempts: {
        Row: {
          answers: Json
          attempt_number: number
          completed_at: string
          correct_answers: number
          created_at: string | null
          id: string
          is_passed: boolean
          passing_score: number
          profile_id: string
          score_percentage: number
          started_at: string
          target_role: string
          time_taken_seconds: number | null
          total_questions: number
        }
        Insert: {
          answers: Json
          attempt_number: number
          completed_at: string
          correct_answers: number
          created_at?: string | null
          id?: string
          is_passed: boolean
          passing_score: number
          profile_id: string
          score_percentage: number
          started_at: string
          target_role: string
          time_taken_seconds?: number | null
          total_questions: number
        }
        Update: {
          answers?: Json
          attempt_number?: number
          completed_at?: string
          correct_answers?: number
          created_at?: string | null
          id?: string
          is_passed?: boolean
          passing_score?: number
          profile_id?: string
          score_percentage?: number
          started_at?: string
          target_role?: string
          time_taken_seconds?: number | null
          total_questions?: number
        }
        Relationships: [
          {
            foreignKeyName: "quiz_attempts_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      quiz_questions: {
        Row: {
          correct_option_ids: string[] | null
          created_at: string | null
          explanation: string | null
          id: string
          is_active: boolean | null
          options: Json
          points: number | null
          question_text: string
          question_type: string | null
          sequence_order: number | null
          target_role: string
          updated_at: string | null
        }
        Insert: {
          correct_option_ids?: string[] | null
          created_at?: string | null
          explanation?: string | null
          id?: string
          is_active?: boolean | null
          options: Json
          points?: number | null
          question_text: string
          question_type?: string | null
          sequence_order?: number | null
          target_role: string
          updated_at?: string | null
        }
        Update: {
          correct_option_ids?: string[] | null
          created_at?: string | null
          explanation?: string | null
          id?: string
          is_active?: boolean | null
          options?: Json
          points?: number | null
          question_text?: string
          question_type?: string | null
          sequence_order?: number | null
          target_role?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      reference_styles: {
        Row: {
          created_at: string | null
          description: string | null
          id: string
          is_active: boolean | null
          name: string
          version: string | null
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          version?: string | null
        }
        Update: {
          created_at?: string | null
          description?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          version?: string | null
        }
        Relationships: []
      }
      referral_codes: {
        Row: {
          code: string
          code_type: string
          created_at: string | null
          current_uses: number | null
          description: string | null
          discount_type: string
          discount_value: number
          id: string
          is_active: boolean | null
          max_discount: number | null
          max_uses: number | null
          max_uses_per_user: number | null
          min_order_value: number | null
          owner_id: string | null
          updated_at: string | null
          valid_from: string | null
          valid_until: string | null
        }
        Insert: {
          code: string
          code_type: string
          created_at?: string | null
          current_uses?: number | null
          description?: string | null
          discount_type: string
          discount_value: number
          id?: string
          is_active?: boolean | null
          max_discount?: number | null
          max_uses?: number | null
          max_uses_per_user?: number | null
          min_order_value?: number | null
          owner_id?: string | null
          updated_at?: string | null
          valid_from?: string | null
          valid_until?: string | null
        }
        Update: {
          code?: string
          code_type?: string
          created_at?: string | null
          current_uses?: number | null
          description?: string | null
          discount_type?: string
          discount_value?: number
          id?: string
          is_active?: boolean | null
          max_discount?: number | null
          max_uses?: number | null
          max_uses_per_user?: number | null
          min_order_value?: number | null
          owner_id?: string | null
          updated_at?: string | null
          valid_from?: string | null
          valid_until?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "referral_codes_owner_id_fkey"
            columns: ["owner_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      referral_usage: {
        Row: {
          discount_applied: number
          id: string
          payment_id: string | null
          project_id: string | null
          referral_code_id: string
          used_at: string | null
          used_by: string
        }
        Insert: {
          discount_applied: number
          id?: string
          payment_id?: string | null
          project_id?: string | null
          referral_code_id: string
          used_at?: string | null
          used_by: string
        }
        Update: {
          discount_applied?: number
          id?: string
          payment_id?: string | null
          project_id?: string | null
          referral_code_id?: string
          used_at?: string | null
          used_by?: string
        }
        Relationships: [
          {
            foreignKeyName: "referral_usage_payment_id_fkey"
            columns: ["payment_id"]
            isOneToOne: false
            referencedRelation: "payments"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referral_usage_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referral_usage_referral_code_id_fkey"
            columns: ["referral_code_id"]
            isOneToOne: false
            referencedRelation: "referral_codes"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "referral_usage_used_by_fkey"
            columns: ["used_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      skills: {
        Row: {
          category: string | null
          created_at: string | null
          id: string
          is_active: boolean | null
          name: string
          slug: string
          subject_id: string | null
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          slug: string
          subject_id?: string | null
        }
        Update: {
          category?: string | null
          created_at?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          slug?: string
          subject_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "skills_subject_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "subjects"
            referencedColumns: ["id"]
          },
        ]
      }
      students: {
        Row: {
          college_email: string | null
          college_email_verified: boolean | null
          course_id: string | null
          created_at: string | null
          expected_graduation_year: number | null
          id: string
          preferred_subjects: string[] | null
          profile_id: string
          semester: number | null
          student_id_number: string | null
          student_id_verified: boolean | null
          university_id: string | null
          updated_at: string | null
          year_of_study: number | null
        }
        Insert: {
          college_email?: string | null
          college_email_verified?: boolean | null
          course_id?: string | null
          created_at?: string | null
          expected_graduation_year?: number | null
          id?: string
          preferred_subjects?: string[] | null
          profile_id: string
          semester?: number | null
          student_id_number?: string | null
          student_id_verified?: boolean | null
          university_id?: string | null
          updated_at?: string | null
          year_of_study?: number | null
        }
        Update: {
          college_email?: string | null
          college_email_verified?: boolean | null
          course_id?: string | null
          created_at?: string | null
          expected_graduation_year?: number | null
          id?: string
          preferred_subjects?: string[] | null
          profile_id?: string
          semester?: number | null
          student_id_number?: string | null
          student_id_verified?: boolean | null
          university_id?: string | null
          updated_at?: string | null
          year_of_study?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "students_course_id_fkey"
            columns: ["course_id"]
            isOneToOne: false
            referencedRelation: "courses"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "students_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "students_university_id_fkey"
            columns: ["university_id"]
            isOneToOne: false
            referencedRelation: "universities"
            referencedColumns: ["id"]
          },
        ]
      }
      subjects: {
        Row: {
          category: string | null
          created_at: string | null
          description: string | null
          display_order: number | null
          icon: string | null
          id: string
          is_active: boolean | null
          name: string
          parent_id: string | null
          slug: string
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          display_order?: number | null
          icon?: string | null
          id?: string
          is_active?: boolean | null
          name: string
          parent_id?: string | null
          slug: string
        }
        Update: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          display_order?: number | null
          icon?: string | null
          id?: string
          is_active?: boolean | null
          name?: string
          parent_id?: string | null
          slug?: string
        }
        Relationships: [
          {
            foreignKeyName: "subjects_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "subjects"
            referencedColumns: ["id"]
          },
        ]
      }
      supervisor_activation: {
        Row: {
          activated_at: string | null
          bank_details_added: boolean | null
          bank_details_added_at: string | null
          created_at: string | null
          cv_rejection_reason: string | null
          cv_submitted: boolean | null
          cv_submitted_at: string | null
          cv_verified: boolean | null
          cv_verified_at: string | null
          cv_verified_by: string | null
          id: string
          is_fully_activated: boolean | null
          quiz_attempt_id: string | null
          quiz_passed: boolean | null
          quiz_passed_at: string | null
          supervisor_id: string
          total_quiz_attempts: number | null
          training_completed: boolean | null
          training_completed_at: string | null
          updated_at: string | null
        }
        Insert: {
          activated_at?: string | null
          bank_details_added?: boolean | null
          bank_details_added_at?: string | null
          created_at?: string | null
          cv_rejection_reason?: string | null
          cv_submitted?: boolean | null
          cv_submitted_at?: string | null
          cv_verified?: boolean | null
          cv_verified_at?: string | null
          cv_verified_by?: string | null
          id?: string
          is_fully_activated?: boolean | null
          quiz_attempt_id?: string | null
          quiz_passed?: boolean | null
          quiz_passed_at?: string | null
          supervisor_id: string
          total_quiz_attempts?: number | null
          training_completed?: boolean | null
          training_completed_at?: string | null
          updated_at?: string | null
        }
        Update: {
          activated_at?: string | null
          bank_details_added?: boolean | null
          bank_details_added_at?: string | null
          created_at?: string | null
          cv_rejection_reason?: string | null
          cv_submitted?: boolean | null
          cv_submitted_at?: string | null
          cv_verified?: boolean | null
          cv_verified_at?: string | null
          cv_verified_by?: string | null
          id?: string
          is_fully_activated?: boolean | null
          quiz_attempt_id?: string | null
          quiz_passed?: boolean | null
          quiz_passed_at?: string | null
          supervisor_id?: string
          total_quiz_attempts?: number | null
          training_completed?: boolean | null
          training_completed_at?: string | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "supervisor_activation_cv_verified_by_fkey"
            columns: ["cv_verified_by"]
            isOneToOne: false
            referencedRelation: "admins"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "supervisor_activation_quiz_attempt_id_fkey"
            columns: ["quiz_attempt_id"]
            isOneToOne: false
            referencedRelation: "quiz_attempts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "supervisor_activation_supervisor_id_fkey"
            columns: ["supervisor_id"]
            isOneToOne: true
            referencedRelation: "supervisors"
            referencedColumns: ["id"]
          },
        ]
      }
      supervisor_blacklisted_doers: {
        Row: {
          created_at: string | null
          doer_id: string
          id: string
          reason: string | null
          supervisor_id: string
        }
        Insert: {
          created_at?: string | null
          doer_id: string
          id?: string
          reason?: string | null
          supervisor_id: string
        }
        Update: {
          created_at?: string | null
          doer_id?: string
          id?: string
          reason?: string | null
          supervisor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "supervisor_blacklisted_doers_doer_id_fkey"
            columns: ["doer_id"]
            isOneToOne: false
            referencedRelation: "doers"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "supervisor_blacklisted_doers_supervisor_id_fkey"
            columns: ["supervisor_id"]
            isOneToOne: false
            referencedRelation: "supervisors"
            referencedColumns: ["id"]
          },
        ]
      }
      supervisor_expertise: {
        Row: {
          created_at: string | null
          id: string
          is_primary: boolean | null
          subject_id: string
          supervisor_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          is_primary?: boolean | null
          subject_id: string
          supervisor_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          is_primary?: boolean | null
          subject_id?: string
          supervisor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "supervisor_expertise_subject_id_fkey"
            columns: ["subject_id"]
            isOneToOne: false
            referencedRelation: "subjects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "supervisor_expertise_supervisor_id_fkey"
            columns: ["supervisor_id"]
            isOneToOne: false
            referencedRelation: "supervisors"
            referencedColumns: ["id"]
          },
        ]
      }
      supervisor_reviews: {
        Row: {
          communication_rating: number | null
          created_at: string | null
          helpfulness_rating: number | null
          id: string
          is_public: boolean | null
          overall_rating: number
          project_id: string | null
          review_text: string | null
          reviewer_id: string
          reviewer_type: string
          supervisor_id: string
        }
        Insert: {
          communication_rating?: number | null
          created_at?: string | null
          helpfulness_rating?: number | null
          id?: string
          is_public?: boolean | null
          overall_rating: number
          project_id?: string | null
          review_text?: string | null
          reviewer_id: string
          reviewer_type: string
          supervisor_id: string
        }
        Update: {
          communication_rating?: number | null
          created_at?: string | null
          helpfulness_rating?: number | null
          id?: string
          is_public?: boolean | null
          overall_rating?: number
          project_id?: string | null
          review_text?: string | null
          reviewer_id?: string
          reviewer_type?: string
          supervisor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "supervisor_reviews_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "supervisor_reviews_reviewer_id_fkey"
            columns: ["reviewer_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "supervisor_reviews_supervisor_id_fkey"
            columns: ["supervisor_id"]
            isOneToOne: false
            referencedRelation: "supervisors"
            referencedColumns: ["id"]
          },
        ]
      }
      supervisors: {
        Row: {
          activated_at: string | null
          availability_updated_at: string | null
          average_rating: number | null
          average_response_time_hours: number | null
          bank_account_name: string | null
          bank_account_number: string | null
          bank_ifsc_code: string | null
          bank_name: string | null
          bank_verified: boolean | null
          created_at: string | null
          cv_url: string | null
          cv_verified: boolean | null
          cv_verified_at: string | null
          cv_verified_by: string | null
          id: string
          is_activated: boolean | null
          is_available: boolean | null
          max_concurrent_projects: number | null
          profile_id: string
          qualification: string
          success_rate: number | null
          total_earnings: number | null
          total_projects_managed: number | null
          total_reviews: number | null
          updated_at: string | null
          upi_id: string | null
          years_of_experience: number
        }
        Insert: {
          activated_at?: string | null
          availability_updated_at?: string | null
          average_rating?: number | null
          average_response_time_hours?: number | null
          bank_account_name?: string | null
          bank_account_number?: string | null
          bank_ifsc_code?: string | null
          bank_name?: string | null
          bank_verified?: boolean | null
          created_at?: string | null
          cv_url?: string | null
          cv_verified?: boolean | null
          cv_verified_at?: string | null
          cv_verified_by?: string | null
          id?: string
          is_activated?: boolean | null
          is_available?: boolean | null
          max_concurrent_projects?: number | null
          profile_id: string
          qualification: string
          success_rate?: number | null
          total_earnings?: number | null
          total_projects_managed?: number | null
          total_reviews?: number | null
          updated_at?: string | null
          upi_id?: string | null
          years_of_experience: number
        }
        Update: {
          activated_at?: string | null
          availability_updated_at?: string | null
          average_rating?: number | null
          average_response_time_hours?: number | null
          bank_account_name?: string | null
          bank_account_number?: string | null
          bank_ifsc_code?: string | null
          bank_name?: string | null
          bank_verified?: boolean | null
          created_at?: string | null
          cv_url?: string | null
          cv_verified?: boolean | null
          cv_verified_at?: string | null
          cv_verified_by?: string | null
          id?: string
          is_activated?: boolean | null
          is_available?: boolean | null
          max_concurrent_projects?: number | null
          profile_id?: string
          qualification?: string
          success_rate?: number | null
          total_earnings?: number | null
          total_projects_managed?: number | null
          total_reviews?: number | null
          updated_at?: string | null
          upi_id?: string | null
          years_of_experience?: number
        }
        Relationships: [
          {
            foreignKeyName: "supervisors_cv_verified_by_fkey"
            columns: ["cv_verified_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "supervisors_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      support_tickets: {
        Row: {
          assigned_at: string | null
          assigned_to: string | null
          category: string | null
          closed_at: string | null
          created_at: string | null
          description: string
          first_response_at: string | null
          id: string
          priority: Database["public"]["Enums"]["ticket_priority"] | null
          project_id: string | null
          requester_id: string
          resolution_notes: string | null
          resolved_at: string | null
          resolved_by: string | null
          satisfaction_feedback: string | null
          satisfaction_rating: number | null
          status: Database["public"]["Enums"]["ticket_status"] | null
          subject: string
          ticket_number: string
          updated_at: string | null
        }
        Insert: {
          assigned_at?: string | null
          assigned_to?: string | null
          category?: string | null
          closed_at?: string | null
          created_at?: string | null
          description: string
          first_response_at?: string | null
          id?: string
          priority?: Database["public"]["Enums"]["ticket_priority"] | null
          project_id?: string | null
          requester_id: string
          resolution_notes?: string | null
          resolved_at?: string | null
          resolved_by?: string | null
          satisfaction_feedback?: string | null
          satisfaction_rating?: number | null
          status?: Database["public"]["Enums"]["ticket_status"] | null
          subject: string
          ticket_number: string
          updated_at?: string | null
        }
        Update: {
          assigned_at?: string | null
          assigned_to?: string | null
          category?: string | null
          closed_at?: string | null
          created_at?: string | null
          description?: string
          first_response_at?: string | null
          id?: string
          priority?: Database["public"]["Enums"]["ticket_priority"] | null
          project_id?: string | null
          requester_id?: string
          resolution_notes?: string | null
          resolved_at?: string | null
          resolved_by?: string | null
          satisfaction_feedback?: string | null
          satisfaction_rating?: number | null
          status?: Database["public"]["Enums"]["ticket_status"] | null
          subject?: string
          ticket_number?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "support_tickets_assigned_to_fkey"
            columns: ["assigned_to"]
            isOneToOne: false
            referencedRelation: "admins"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "support_tickets_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "support_tickets_requester_id_fkey"
            columns: ["requester_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "support_tickets_resolved_by_fkey"
            columns: ["resolved_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      ticket_messages: {
        Row: {
          attachments: Json | null
          created_at: string | null
          id: string
          is_internal: boolean | null
          message: string
          sender_id: string
          sender_type: string
          ticket_id: string
        }
        Insert: {
          attachments?: Json | null
          created_at?: string | null
          id?: string
          is_internal?: boolean | null
          message: string
          sender_id: string
          sender_type: string
          ticket_id: string
        }
        Update: {
          attachments?: Json | null
          created_at?: string | null
          id?: string
          is_internal?: boolean | null
          message?: string
          sender_id?: string
          sender_type?: string
          ticket_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "ticket_messages_sender_id_fkey"
            columns: ["sender_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ticket_messages_ticket_id_fkey"
            columns: ["ticket_id"]
            isOneToOne: false
            referencedRelation: "support_tickets"
            referencedColumns: ["id"]
          },
        ]
      }
      training_modules: {
        Row: {
          content_html: string | null
          content_type: string
          content_url: string | null
          created_at: string | null
          description: string | null
          duration_minutes: number | null
          id: string
          is_active: boolean | null
          is_mandatory: boolean | null
          sequence_order: number
          target_role: string
          title: string
          updated_at: string | null
        }
        Insert: {
          content_html?: string | null
          content_type: string
          content_url?: string | null
          created_at?: string | null
          description?: string | null
          duration_minutes?: number | null
          id?: string
          is_active?: boolean | null
          is_mandatory?: boolean | null
          sequence_order: number
          target_role: string
          title: string
          updated_at?: string | null
        }
        Update: {
          content_html?: string | null
          content_type?: string
          content_url?: string | null
          created_at?: string | null
          description?: string | null
          duration_minutes?: number | null
          id?: string
          is_active?: boolean | null
          is_mandatory?: boolean | null
          sequence_order?: number
          target_role?: string
          title?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      training_progress: {
        Row: {
          completed_at: string | null
          created_at: string | null
          id: string
          module_id: string
          profile_id: string
          progress_percentage: number | null
          started_at: string | null
          status: string | null
          time_spent_minutes: number | null
          updated_at: string | null
        }
        Insert: {
          completed_at?: string | null
          created_at?: string | null
          id?: string
          module_id: string
          profile_id: string
          progress_percentage?: number | null
          started_at?: string | null
          status?: string | null
          time_spent_minutes?: number | null
          updated_at?: string | null
        }
        Update: {
          completed_at?: string | null
          created_at?: string | null
          id?: string
          module_id?: string
          profile_id?: string
          progress_percentage?: number | null
          started_at?: string | null
          status?: string | null
          time_spent_minutes?: number | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "training_progress_module_id_fkey"
            columns: ["module_id"]
            isOneToOne: false
            referencedRelation: "training_modules"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "training_progress_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      universities: {
        Row: {
          city: string | null
          country: string | null
          created_at: string | null
          email_domains: string[] | null
          id: string
          is_active: boolean | null
          name: string
          short_name: string | null
          state: string | null
        }
        Insert: {
          city?: string | null
          country?: string | null
          created_at?: string | null
          email_domains?: string[] | null
          id?: string
          is_active?: boolean | null
          name: string
          short_name?: string | null
          state?: string | null
        }
        Update: {
          city?: string | null
          country?: string | null
          created_at?: string | null
          email_domains?: string[] | null
          id?: string
          is_active?: boolean | null
          name?: string
          short_name?: string | null
          state?: string | null
        }
        Relationships: []
      }
      user_feedback: {
        Row: {
          created_at: string | null
          feedback_text: string | null
          id: string
          improvement_suggestions: string | null
          nps_score: number | null
          overall_satisfaction: number
          project_id: string | null
          user_id: string
          would_recommend: boolean | null
        }
        Insert: {
          created_at?: string | null
          feedback_text?: string | null
          id?: string
          improvement_suggestions?: string | null
          nps_score?: number | null
          overall_satisfaction: number
          project_id?: string | null
          user_id: string
          would_recommend?: boolean | null
        }
        Update: {
          created_at?: string | null
          feedback_text?: string | null
          id?: string
          improvement_suggestions?: string | null
          nps_score?: number | null
          overall_satisfaction?: number
          project_id?: string | null
          user_id?: string
          would_recommend?: boolean | null
        }
        Relationships: [
          {
            foreignKeyName: "user_feedback_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "user_feedback_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      wallet_transactions: {
        Row: {
          amount: number
          balance_after: number
          balance_before: number
          created_at: string | null
          description: string | null
          id: string
          notes: string | null
          reference_id: string | null
          reference_type: string | null
          status: string | null
          transaction_type: Database["public"]["Enums"]["transaction_type"]
          wallet_id: string
        }
        Insert: {
          amount: number
          balance_after: number
          balance_before: number
          created_at?: string | null
          description?: string | null
          id?: string
          notes?: string | null
          reference_id?: string | null
          reference_type?: string | null
          status?: string | null
          transaction_type: Database["public"]["Enums"]["transaction_type"]
          wallet_id: string
        }
        Update: {
          amount?: number
          balance_after?: number
          balance_before?: number
          created_at?: string | null
          description?: string | null
          id?: string
          notes?: string | null
          reference_id?: string | null
          reference_type?: string | null
          status?: string | null
          transaction_type?: Database["public"]["Enums"]["transaction_type"]
          wallet_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "wallet_transactions_wallet_id_fkey"
            columns: ["wallet_id"]
            isOneToOne: false
            referencedRelation: "wallets"
            referencedColumns: ["id"]
          },
        ]
      }
      wallets: {
        Row: {
          balance: number
          created_at: string | null
          currency: string | null
          id: string
          locked_amount: number | null
          profile_id: string
          total_credited: number | null
          total_debited: number | null
          total_withdrawn: number | null
          updated_at: string | null
        }
        Insert: {
          balance?: number
          created_at?: string | null
          currency?: string | null
          id?: string
          locked_amount?: number | null
          profile_id: string
          total_credited?: number | null
          total_debited?: number | null
          total_withdrawn?: number | null
          updated_at?: string | null
        }
        Update: {
          balance?: number
          created_at?: string | null
          currency?: string | null
          id?: string
          locked_amount?: number | null
          profile_id?: string
          total_credited?: number | null
          total_debited?: number | null
          total_withdrawn?: number | null
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "wallets_profile_id_fkey"
            columns: ["profile_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      chat_room_type:
        | "project_user_supervisor"
        | "project_supervisor_doer"
        | "project_all"
        | "support"
        | "direct"
      listing_status:
        | "draft"
        | "pending_review"
        | "active"
        | "sold"
        | "rented"
        | "expired"
        | "rejected"
        | "removed"
      listing_type:
        | "sell"
        | "rent"
        | "free"
        | "opportunity"
        | "housing"
        | "community_post"
        | "poll"
        | "event"
      message_type: "text" | "file" | "image" | "system" | "action"
      notification_type:
        | "project_submitted"
        | "quote_ready"
        | "payment_received"
        | "project_assigned"
        | "task_available"
        | "task_assigned"
        | "work_submitted"
        | "qc_approved"
        | "qc_rejected"
        | "revision_requested"
        | "project_delivered"
        | "project_completed"
        | "new_message"
        | "payout_processed"
        | "system_alert"
        | "promotional"
      payment_status:
        | "initiated"
        | "pending"
        | "processing"
        | "completed"
        | "failed"
        | "cancelled"
        | "refunded"
        | "partially_refunded"
      payout_status:
        | "pending"
        | "processing"
        | "completed"
        | "failed"
        | "cancelled"
      project_status:
        | "draft"
        | "submitted"
        | "analyzing"
        | "quoted"
        | "payment_pending"
        | "paid"
        | "assigning"
        | "assigned"
        | "in_progress"
        | "submitted_for_qc"
        | "qc_in_progress"
        | "qc_approved"
        | "qc_rejected"
        | "delivered"
        | "revision_requested"
        | "in_revision"
        | "completed"
        | "auto_approved"
        | "cancelled"
        | "refunded"
      service_type:
        | "new_project"
        | "proofreading"
        | "plagiarism_check"
        | "ai_detection"
        | "expert_opinion"
      ticket_priority: "low" | "medium" | "high" | "urgent"
      ticket_status:
        | "open"
        | "in_progress"
        | "waiting_response"
        | "resolved"
        | "closed"
        | "reopened"
      transaction_type:
        | "credit"
        | "debit"
        | "refund"
        | "withdrawal"
        | "top_up"
        | "project_payment"
        | "project_earning"
        | "commission"
        | "bonus"
        | "penalty"
        | "reversal"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      chat_room_type: [
        "project_user_supervisor",
        "project_supervisor_doer",
        "project_all",
        "support",
        "direct",
      ],
      listing_status: [
        "draft",
        "pending_review",
        "active",
        "sold",
        "rented",
        "expired",
        "rejected",
        "removed",
      ],
      listing_type: [
        "sell",
        "rent",
        "free",
        "opportunity",
        "housing",
        "community_post",
        "poll",
        "event",
      ],
      message_type: ["text", "file", "image", "system", "action"],
      notification_type: [
        "project_submitted",
        "quote_ready",
        "payment_received",
        "project_assigned",
        "task_available",
        "task_assigned",
        "work_submitted",
        "qc_approved",
        "qc_rejected",
        "revision_requested",
        "project_delivered",
        "project_completed",
        "new_message",
        "payout_processed",
        "system_alert",
        "promotional",
      ],
      payment_status: [
        "initiated",
        "pending",
        "processing",
        "completed",
        "failed",
        "cancelled",
        "refunded",
        "partially_refunded",
      ],
      payout_status: [
        "pending",
        "processing",
        "completed",
        "failed",
        "cancelled",
      ],
      project_status: [
        "draft",
        "submitted",
        "analyzing",
        "quoted",
        "payment_pending",
        "paid",
        "assigning",
        "assigned",
        "in_progress",
        "submitted_for_qc",
        "qc_in_progress",
        "qc_approved",
        "qc_rejected",
        "delivered",
        "revision_requested",
        "in_revision",
        "completed",
        "auto_approved",
        "cancelled",
        "refunded",
      ],
      service_type: [
        "new_project",
        "proofreading",
        "plagiarism_check",
        "ai_detection",
        "expert_opinion",
      ],
      ticket_priority: ["low", "medium", "high", "urgent"],
      ticket_status: [
        "open",
        "in_progress",
        "waiting_response",
        "resolved",
        "closed",
        "reopened",
      ],
      transaction_type: [
        "credit",
        "debit",
        "refund",
        "withdrawal",
        "top_up",
        "project_payment",
        "project_earning",
        "commission",
        "bonus",
        "penalty",
        "reversal",
      ],
    },
  },
} as const
