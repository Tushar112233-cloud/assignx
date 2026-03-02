"use server";

import { cookies } from "next/headers";
import { serverApiClient } from "@/lib/api/client";

interface InvoiceData {
  invoiceNumber: string;
  projectNumber: string;
  projectTitle: string;
  customerName: string;
  customerEmail: string;
  customerPhone?: string;
  universityName?: string;
  servicetype: string;
  amount: number;
  taxAmount: number;
  totalAmount: number;
  paymentMethod?: string;
  paymentDate: string;
  createdAt: string;
  items: {
    description: string;
    quantity: number;
    unitPrice: number;
    total: number;
  }[];
}

async function getToken(): Promise<string | null> {
  const cookieStore = await cookies();
  return cookieStore.get("accessToken")?.value || null;
}

/**
 * Get invoice data for a completed project
 */
export async function getInvoiceData(projectId: string): Promise<InvoiceData | null> {
  const token = await getToken();
  if (!token) return null;

  try {
    const project = await serverApiClient(`/api/projects/${projectId}`, {}, token);
    const p = project.project || project.data || project;

    if (!p) return null;

    const invoiceableStatuses = ["paid", "assigning", "assigned", "in_progress", "submitted_for_qc", "qc_in_progress", "qc_approved", "qc_rejected", "delivered", "revision_requested", "in_revision", "completed", "auto_approved"];
    if (!invoiceableStatuses.includes(p.status)) return null;
    if (!p.is_paid && !p.isPaid) return null;

    const profile = await serverApiClient("/api/profiles/me", {}, token);

    const acceptedQuote = p.quotes?.find((q: any) => q.status === "accepted");
    const baseAmount = acceptedQuote?.user_amount || p.user_quote || p.userQuote || 0;
    const taxRate = 0.18;
    const taxAmount = Math.round(baseAmount * taxRate);
    const totalAmount = baseAmount + taxAmount;

    const projectNumber = p.project_number || p.projectNumber || "";
    const invoiceNumber = `INV-${projectNumber.replace("AX-", "")}`;

    const serviceLabels: Record<string, string> = {
      new_project: "Project Support",
      proofreading: "Proofreading Service",
      plagiarism_check: "Plagiarism Check",
      ai_detection: "AI Detection Report",
      expert_opinion: "Expert Consultation",
    };

    const serviceType = p.service_type || p.serviceType || "";

    return {
      invoiceNumber,
      projectNumber,
      projectTitle: p.title,
      customerName: profile?.full_name || profile?.fullName || "Customer",
      customerEmail: profile?.email || "",
      customerPhone: profile?.phone,
      universityName: profile?.students?.university?.name || profile?.university?.name,
      servicetype: serviceLabels[serviceType] || serviceType,
      amount: baseAmount,
      taxAmount,
      totalAmount,
      paymentMethod: "Online Payment",
      paymentDate: p.updated_at || p.updatedAt,
      createdAt: p.created_at || p.createdAt,
      items: [
        {
          description: `${serviceLabels[serviceType] || "Service"} - ${p.title}`,
          quantity: 1,
          unitPrice: baseAmount,
          total: baseAmount,
        },
      ],
    };
  } catch {
    return null;
  }
}

/**
 * Generate invoice HTML
 */
export async function generateInvoiceHTML(projectId: string): Promise<string | null> {
  const invoice = await getInvoiceData(projectId);
  if (!invoice) return null;

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleDateString("en-IN", {
      day: "numeric",
      month: "long",
      year: "numeric",
    });
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("en-IN", {
      style: "currency",
      currency: "INR",
      minimumFractionDigits: 0,
    }).format(amount);
  };

  return `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Invoice ${invoice.invoiceNumber}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Segoe UI', Arial, sans-serif; color: #333; background: #fff; }
    .invoice { max-width: 800px; margin: 0 auto; padding: 40px; }
    .header { display: flex; justify-content: space-between; margin-bottom: 40px; }
    .logo { font-size: 28px; font-weight: bold; color: #6366f1; }
    .invoice-info { text-align: right; }
    .invoice-number { font-size: 24px; font-weight: bold; color: #333; }
    .invoice-date { color: #666; margin-top: 4px; }
    .parties { display: flex; justify-content: space-between; margin-bottom: 40px; }
    .party { flex: 1; }
    .party-label { font-size: 12px; text-transform: uppercase; color: #666; margin-bottom: 8px; }
    .party-name { font-size: 16px; font-weight: 600; }
    .party-detail { color: #666; margin-top: 4px; font-size: 14px; }
    table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
    th { background: #f8f9fa; padding: 12px; text-align: left; font-weight: 600; border-bottom: 2px solid #e5e7eb; }
    td { padding: 12px; border-bottom: 1px solid #e5e7eb; }
    .amount { text-align: right; }
    .totals { margin-left: auto; width: 300px; }
    .total-row { display: flex; justify-content: space-between; padding: 8px 0; }
    .total-row.final { font-size: 18px; font-weight: bold; border-top: 2px solid #333; margin-top: 8px; padding-top: 16px; }
    .footer { margin-top: 60px; text-align: center; color: #666; font-size: 12px; }
    .paid-stamp { position: absolute; top: 50%; right: 40px; transform: rotate(-15deg); font-size: 48px; font-weight: bold; color: rgba(34, 197, 94, 0.3); border: 4px solid; padding: 10px 20px; border-radius: 8px; }
    @media print { body { print-color-adjust: exact; -webkit-print-color-adjust: exact; } }
  </style>
</head>
<body>
  <div class="invoice">
    <div class="paid-stamp">PAID</div>
    <div class="header">
      <div class="logo">AssignX</div>
      <div class="invoice-info">
        <div class="invoice-number">${invoice.invoiceNumber}</div>
        <div class="invoice-date">Date: ${formatDate(invoice.paymentDate)}</div>
      </div>
    </div>
    <div class="parties">
      <div class="party">
        <div class="party-label">Bill To</div>
        <div class="party-name">${invoice.customerName}</div>
        <div class="party-detail">${invoice.customerEmail}</div>
        ${invoice.customerPhone ? `<div class="party-detail">${invoice.customerPhone}</div>` : ""}
        ${invoice.universityName ? `<div class="party-detail">${invoice.universityName}</div>` : ""}
      </div>
      <div class="party" style="text-align: right;">
        <div class="party-label">Project</div>
        <div class="party-name">${invoice.projectNumber}</div>
        <div class="party-detail">${invoice.servicetype}</div>
      </div>
    </div>
    <table>
      <thead>
        <tr>
          <th>Description</th>
          <th class="amount">Qty</th>
          <th class="amount">Unit Price</th>
          <th class="amount">Amount</th>
        </tr>
      </thead>
      <tbody>
        ${invoice.items.map((item) => `
          <tr>
            <td>${item.description}</td>
            <td class="amount">${item.quantity}</td>
            <td class="amount">${formatCurrency(item.unitPrice)}</td>
            <td class="amount">${formatCurrency(item.total)}</td>
          </tr>
        `).join("")}
      </tbody>
    </table>
    <div class="totals">
      <div class="total-row">
        <span>Subtotal</span>
        <span>${formatCurrency(invoice.amount)}</span>
      </div>
      <div class="total-row">
        <span>GST (18%)</span>
        <span>${formatCurrency(invoice.taxAmount)}</span>
      </div>
      <div class="total-row final">
        <span>Total</span>
        <span>${formatCurrency(invoice.totalAmount)}</span>
      </div>
    </div>
    <div style="margin-top: 40px; padding: 16px; background: #f0fdf4; border-radius: 8px;">
      <div style="color: #166534; font-weight: 600;">Payment Received</div>
      <div style="color: #166534; font-size: 14px; margin-top: 4px;">
        Paid via ${invoice.paymentMethod} on ${formatDate(invoice.paymentDate)}
      </div>
    </div>
    <div class="footer">
      <p>Thank you for choosing AssignX!</p>
      <p style="margin-top: 8px;">Questions? Contact support@assignx.com</p>
    </div>
  </div>
</body>
</html>
  `.trim();
}
