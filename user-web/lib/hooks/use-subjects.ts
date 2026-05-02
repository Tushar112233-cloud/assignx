"use client";

import { useState, useEffect, useCallback } from "react";
import { apiClient } from "@/lib/api/client";

/** Subject as returned by the API */
export interface ApiSubject {
  _id: string;
  name: string;
  slug: string;
  category: string;
  isActive: boolean;
}

/**
 * Fetches the list of subjects from the API.
 * Returns the subjects array, loading state, error, and a retry function.
 */
export function useSubjects() {
  const [subjects, setSubjects] = useState<ApiSubject[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchSubjects = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await apiClient<{ subjects: ApiSubject[] }>("/api/subjects");
      setSubjects(data.subjects);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load subjects");
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchSubjects();
  }, [fetchSubjects]);

  return { subjects, isLoading, error, retry: fetchSubjects };
}
