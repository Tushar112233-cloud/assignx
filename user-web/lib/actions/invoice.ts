"use server";

import { createClient } from "@/lib/supabase/server";

/**
 * Invoice data structure
 */
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

/**
 * Get invoice data for a completed project
 * @param projectId - The project UUID
 * @returns Invoice data or null
 */
export async function getInvoiceData(projectId: string): Promise<InvoiceData | null> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) return null;

  // Fetch project with related data
  const { data: project, error } = await supabase
    .from("projects")
    .select(`
      *,
      subject:subjects (name),
      quotes:project_quotes (*)
    `)
    .eq("id", projectId)
    .eq("user_id", user.id)
    .single();

  if (error || !project) return null;

  // Generate invoice for paid and completed projects
  // Invoice is available once payment is confirmed
  const invoiceableStatuses = ["paid", "assigning", "assigned", "in_progress", "submitted_for_qc", "qc_in_progress", "qc_approved", "qc_rejected", "delivered", "revision_requested", "in_revision", "completed", "auto_approved"];
  if (!invoiceableStatuses.includes(project.status)) return null;

  // Also check if project is actually paid
  if (!project.is_paid) return null;

  // Get user profile
  const { data: profile } = await supabase
    .from("profiles")
    .select(`
      *,
      students (
        university:universities (name)
      )
    `)
    .eq("id", user.id)
    .single();

  // Get the accepted quote
  const acceptedQuote = project.quotes?.find((q: { status: string }) => q.status === "accepted");

  // Calculate amounts - check multiple possible price fields
  const baseAmount = acceptedQuote?.amount || project.user_quote || project.quoted_price || project.final_quote || 0;
  const taxRate = 0.18; // 18% GST
  const taxAmount = Math.round(baseAmount * taxRate);
  const totalAmount = baseAmount + taxAmount;

  // Generate invoice number
  const invoiceNumber = `INV-${project.project_number.replace("AX-", "")}`;

  // Service type labels
  const serviceLabels: Record<string, string> = {
    new_project: "Project Support",
    proofreading: "Proofreading Service",
    plagiarism_check: "Plagiarism Check",
    ai_detection: "AI Detection Report",
    expert_opinion: "Expert Consultation",
  };

  return {
    invoiceNumber,
    projectNumber: project.project_number,
    projectTitle: project.title,
    customerName: profile?.full_name || "Customer",
    customerEmail: profile?.email || user.email || "",
    customerPhone: profile?.phone || undefined,
    universityName: profile?.students?.university?.name,
    servicetype: serviceLabels[project.service_type] || project.service_type,
    amount: baseAmount,
    taxAmount,
    totalAmount,
    paymentMethod: "Online Payment",
    paymentDate: project.updated_at,
    createdAt: project.created_at,
    items: [
      {
        description: `${serviceLabels[project.service_type] || "Service"} - ${project.title}`,
        quantity: 1,
        unitPrice: baseAmount,
        total: baseAmount,
      },
    ],
  };
}

/**
 * Generate invoice PDF (returns base64 encoded PDF)
 * For now, returns HTML that can be printed as PDF
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
        ${invoice.items
          .map(
            (item) => `
          <tr>
            <td>${item.description}</td>
            <td class="amount">${item.quantity}</td>
            <td class="amount">${formatCurrency(item.unitPrice)}</td>
            <td class="amount">${formatCurrency(item.total)}</td>
          </tr>
        `
          )
          .join("")}
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
