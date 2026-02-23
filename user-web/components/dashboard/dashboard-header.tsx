"use client";

import Link from "next/link";
import { WalletPill } from "./wallet-pill";
import { NotificationBell } from "./notification-bell";
import { AnimatedThemeToggler } from "@/components/ui/animated-theme-toggler";

/**
 * Dashboard header component
 * Premium SAAS-style header with glass effect
 */
export function DashboardHeader() {
  return (
    <header className="dashboard-header">
      <div className="dashboard-header-inner">
        {/* Left: Logo/Brand */}
        <Link href="/home" className="dashboard-header-brand">
          <div className="dashboard-header-logo">
            <span className="logo-letter">A</span>
          </div>
          <div className="dashboard-header-brand-text">
            <span className="brand-name">AssignX</span>
            <span className="brand-tag">Dashboard</span>
          </div>
        </Link>

        {/* Right: Actions */}
        <div className="dashboard-header-actions">
          <WalletPill />
          <div className="header-divider" />
          <NotificationBell />
          <AnimatedThemeToggler />
        </div>
      </div>
    </header>
  );
}
