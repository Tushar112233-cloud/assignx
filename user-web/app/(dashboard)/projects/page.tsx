"use client";

import { useState, useEffect, useRef } from "react";
import { PaymentPromptModal } from "@/components/projects";
import { RazorpayCheckout } from "@/components/payments/razorpay-checkout";
import { getStoredUser } from "@/lib/api/auth";
import { walletService } from "@/services";
import { useProjectStore, type Project } from "@/stores";
import { ProjectsPro } from "./projects-pro";

/**
 * My Projects Page
 * Clean, premium design with no unnecessary animations
 */
export default function ProjectsPage() {
  const [showPayment, setShowPayment] = useState(false);
  const [selectedProject, setSelectedProject] = useState<Project | null>(null);
  const [userId, setUserId] = useState<string>("");
  const [userEmail, setUserEmail] = useState<string | undefined>();
  const [userName, setUserName] = useState<string | undefined>();
  const [walletBalance, setWalletBalance] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  // Track if initial fetch has been done to prevent re-fetches
  const hasFetched = useRef(false);

  // Get fetch function from project store
  const { fetchProjects } = useProjectStore();

  // Fetch projects and user data on mount (ONCE)
  useEffect(() => {
    if (hasFetched.current) return;
    hasFetched.current = true;

    const loadData = async () => {
      const user = getStoredUser();

      // Fetch projects
      await fetchProjects();

      if (user) {
        setUserId(user.id);
        setUserEmail(user.email);
        setUserName(user.full_name || user.fullName);

        // Get wallet balance
        try {
          const balance = await walletService.getBalance(user.id);
          setWalletBalance(balance);
        } catch (error) {
          console.error("Failed to get wallet balance:", error);
        }
      }

      setIsLoading(false);
    };

    loadData();
  }, [fetchProjects]);

  const handlePayNow = (project: Project) => {
    setSelectedProject(project);
    setShowPayment(true);
  };

  const handlePaymentSuccess = () => {
    setShowPayment(false);
    setSelectedProject(null);
    window.location.reload();
  };

  const paymentAmount = selectedProject
    ? (selectedProject.quoteAmount || selectedProject.final_quote || selectedProject.user_quote || 0)
    : 0;

  // Use the loading skeleton while data is being fetched
  if (isLoading) {
    // Dynamic import of loading skeleton to avoid SSR issues
    const ProjectsLoading = require("./loading").default;
    return <ProjectsLoading />;
  }

  return (
    <>
      {/* Projects View - Clean Design */}
      <ProjectsPro onPayNow={handlePayNow} />

      {/* Payment Prompt Modal */}
      <PaymentPromptModal onPay={handlePayNow} />

      {/* Razorpay Checkout */}
      {selectedProject && (
        <RazorpayCheckout
          open={showPayment}
          onOpenChange={setShowPayment}
          amount={paymentAmount}
          type="project_payment"
          projectId={selectedProject.id}
          userId={userId}
          userEmail={userEmail}
          userName={userName}
          walletBalance={walletBalance}
          onSuccess={handlePaymentSuccess}
          onError={(error) => {
            console.error("Project payment error:", error);
          }}
        />
      )}
    </>
  );
}
