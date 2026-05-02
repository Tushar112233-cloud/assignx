/**
 * @fileoverview Section displaying new incoming project requests.
 * @module components/dashboard/new-requests-section
 */

"use client"

import { useState } from "react"
import { FileText, RefreshCw } from "lucide-react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Skeleton } from "@/components/ui/skeleton"
import { ScrollArea } from "@/components/ui/scroll-area"
import { RequestCard, type ProjectRequest } from "./request-card"
import { AnalyzeQuoteModal } from "./analyze-quote-modal"

interface NewRequestsSectionProps {
  requests: ProjectRequest[]
  isLoading?: boolean
  onRefresh?: () => void
  onQuoteSubmit?: (requestId: string, data: { userQuote: number; doerPayout: number; notes?: string }) => void
}

export function NewRequestsSection({
  requests,
  isLoading = false,
  onRefresh,
  onQuoteSubmit,
}: NewRequestsSectionProps) {
  const [selectedRequest, setSelectedRequest] = useState<ProjectRequest | null>(null)
  const [isModalOpen, setIsModalOpen] = useState(false)

  const handleAnalyze = (request: ProjectRequest) => {
    setSelectedRequest(request)
    setIsModalOpen(true)
  }

  const handleQuoteSubmit = (requestId: string, data: { userQuote: number; doerPayout: number; notes?: string }) => {
    onQuoteSubmit?.(requestId, data)
    setIsModalOpen(false)
    setSelectedRequest(null)
  }

  return (
    <>
      <Card className="border border-[#E7DED0] bg-white/85 p-6 shadow-sm">
        <CardHeader className="p-0 pb-4 border-b border-[#E7DED0]">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <span className="h-2 w-2 rounded-full bg-[#E48B6A] animate-pulse" />
              <CardTitle className="text-lg text-[#122022]">New Requests</CardTitle>
              {requests.length > 0 && (
                <span className="text-sm text-[#6B7B78]">
                  ({requests.length})
                </span>
              )}
            </div>
            {onRefresh && (
              <Button
                variant="ghost"
                size="sm"
                onClick={onRefresh}
                disabled={isLoading}
              >
                <RefreshCw className={`h-4 w-4 ${isLoading ? "animate-spin" : ""}`} />
              </Button>
            )}
          </div>
          <CardDescription className="mt-1 text-[#5A6B68]">
            Projects awaiting analysis and quote
          </CardDescription>
        </CardHeader>
        <CardContent className="p-0 pt-4">
          {isLoading ? (
            <div className="space-y-4">
              {[1, 2, 3].map((i) => (
                <div
                  key={i}
                  className="p-4 rounded-lg border"
                >
                  <div className="flex items-start gap-4">
                    <div className="flex-1 space-y-2">
                      <div className="flex gap-2">
                        <Skeleton className="h-5 w-20" />
                        <Skeleton className="h-5 w-24" />
                      </div>
                      <Skeleton className="h-5 w-3/4" />
                      <Skeleton className="h-4 w-1/2" />
                      <div className="flex gap-4">
                        <Skeleton className="h-3 w-20" />
                        <Skeleton className="h-3 w-24" />
                        <Skeleton className="h-3 w-16" />
                      </div>
                    </div>
                    <Skeleton className="h-9 w-32" />
                  </div>
                </div>
              ))}
            </div>
          ) : requests.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-center">
              <FileText className="h-12 w-12 text-[#8FA3A0] mb-3" />
              <p className="text-[#5A6B68]">No new requests</p>
              <p className="text-sm text-[#7A8B87]">
                New project requests will appear here
              </p>
            </div>
          ) : (
            <ScrollArea className="h-[560px]">
              <div className="space-y-3 pr-4">
                {requests.map((request) => (
                  <RequestCard
                    key={request.id}
                    request={request}
                    onAnalyze={handleAnalyze}
                  />
                ))}
              </div>
            </ScrollArea>
          )}
        </CardContent>
      </Card>

      <AnalyzeQuoteModal
        request={selectedRequest}
        isOpen={isModalOpen}
        onClose={() => {
          setIsModalOpen(false)
          setSelectedRequest(null)
        }}
        onQuoteSubmit={handleQuoteSubmit}
      />
    </>
  )
}
