import { NextRequest, NextResponse } from "next/server";
import { extractToken, serverFetch } from "@/lib/api/server";

/**
 * GET /api/invoices/[projectId]
 * Generate and return invoice HTML for a project.
 * Data is fetched from the Express API.
 */
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string }> }
) {
  const { projectId } = await params;
  const token = extractToken(request);

  if (!token) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // Fetch invoice data from Express API
  const { data: invoiceData, error, status } = await serverFetch<{
    project: {
      id: string;
      title: string;
      project_number: string;
      service_type?: string;
      word_count?: number;
      quoted_price?: number;
      payment_status?: string;
      created_at: string;
      subject?: { name: string };
    };
    profile: {
      full_name?: string;
      email: string;
      phone?: string;
    };
  }>(`/api/invoices/${projectId}`, token);

  if (error || !invoiceData) {
    // If Express API returns the invoice data, use it.
    // Otherwise fall back to fetching project + profile separately.
    const { data: project } = await serverFetch<any>(
      `/api/projects/${projectId}`,
      token
    );
    const { data: profile } = await serverFetch<any>(
      "/api/auth/me",
      token
    );

    if (!project) {
      return NextResponse.json({ error: "Project not found" }, { status: 404 });
    }

    return generateInvoiceHtml(project, profile);
  }

  return generateInvoiceHtml(invoiceData.project, invoiceData.profile);
}

/**
 * Generate invoice HTML from project and profile data.
 */
function generateInvoiceHtml(project: any, profile: any): NextResponse {
  const invoiceDate = new Date().toLocaleDateString("en-IN", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });

  const projectDate = new Date(project.created_at).toLocaleDateString("en-IN", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });

  const baseAmount = project.quoted_price || (project.word_count ? project.word_count * 0.5 : 999);
  const gst = baseAmount * 0.18;
  const totalAmount = baseAmount + gst;

  const invoiceHtml = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Invoice - ${project.project_number}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Segoe UI', Arial, sans-serif; padding: 40px; color: #333; }
    .invoice { max-width: 800px; margin: 0 auto; }
    .header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 40px; border-bottom: 2px solid #4F46E5; padding-bottom: 20px; }
    .logo { font-size: 28px; font-weight: bold; color: #4F46E5; }
    .invoice-title { text-align: right; }
    .invoice-title h1 { font-size: 24px; color: #333; }
    .invoice-title p { color: #666; margin-top: 5px; }
    .details { display: flex; justify-content: space-between; margin-bottom: 40px; }
    .details-section h3 { font-size: 12px; text-transform: uppercase; color: #666; margin-bottom: 10px; }
    .details-section p { margin: 3px 0; }
    .table { width: 100%; border-collapse: collapse; margin-bottom: 30px; }
    .table th { background: #F3F4F6; padding: 12px; text-align: left; font-size: 12px; text-transform: uppercase; color: #666; }
    .table td { padding: 12px; border-bottom: 1px solid #E5E7EB; }
    .totals { margin-left: auto; width: 300px; }
    .totals-row { display: flex; justify-content: space-between; padding: 8px 0; }
    .totals-row.total { border-top: 2px solid #333; font-weight: bold; font-size: 18px; margin-top: 10px; padding-top: 15px; }
    .footer { margin-top: 60px; text-align: center; color: #666; font-size: 12px; border-top: 1px solid #E5E7EB; padding-top: 20px; }
    .status { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 500; }
    .status.paid { background: #D1FAE5; color: #065F46; }
    .status.pending { background: #FEF3C7; color: #92400E; }
  </style>
</head>
<body>
  <div class="invoice">
    <div class="header">
      <div class="logo">AssignX</div>
      <div class="invoice-title">
        <h1>INVOICE</h1>
        <p>${project.project_number}</p>
        <p style="margin-top: 10px;">
          <span class="status ${project.payment_status === 'paid' ? 'paid' : 'pending'}">
            ${project.payment_status === 'paid' ? 'PAID' : 'PENDING'}
          </span>
        </p>
      </div>
    </div>

    <div class="details">
      <div class="details-section">
        <h3>Billed To</h3>
        <p><strong>${profile?.full_name || 'Customer'}</strong></p>
        <p>${profile?.email || ''}</p>
        ${profile?.phone ? `<p>${profile.phone}</p>` : ''}
      </div>
      <div class="details-section">
        <h3>Invoice Details</h3>
        <p><strong>Invoice Date:</strong> ${invoiceDate}</p>
        <p><strong>Project Date:</strong> ${projectDate}</p>
        <p><strong>Due Date:</strong> ${invoiceDate}</p>
      </div>
    </div>

    <table class="table">
      <thead>
        <tr>
          <th>Description</th>
          <th>Details</th>
          <th style="text-align: right;">Amount</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>
            <strong>${project.title}</strong><br>
            <span style="color: #666; font-size: 14px;">${project.service_type?.replace('_', ' ').toUpperCase() || 'Project Service'}</span>
          </td>
          <td>
            ${project.word_count ? `${project.word_count.toLocaleString()} words` : '-'}<br>
            ${project.subject?.name || '-'}
          </td>
          <td style="text-align: right;">\u20B9${baseAmount.toLocaleString('en-IN', { minimumFractionDigits: 2 })}</td>
        </tr>
      </tbody>
    </table>

    <div class="totals">
      <div class="totals-row">
        <span>Subtotal</span>
        <span>\u20B9${baseAmount.toLocaleString('en-IN', { minimumFractionDigits: 2 })}</span>
      </div>
      <div class="totals-row">
        <span>GST (18%)</span>
        <span>\u20B9${gst.toLocaleString('en-IN', { minimumFractionDigits: 2 })}</span>
      </div>
      <div class="totals-row total">
        <span>Total</span>
        <span>\u20B9${totalAmount.toLocaleString('en-IN', { minimumFractionDigits: 2 })}</span>
      </div>
    </div>

    <div class="footer">
      <p>Thank you for choosing AssignX!</p>
      <p style="margin-top: 5px;">For queries, contact support@assignx.com</p>
    </div>
  </div>
</body>
</html>
  `;

  return new NextResponse(invoiceHtml, {
    headers: {
      "Content-Type": "text/html",
      "Content-Disposition": `attachment; filename="Invoice_${project.project_number}.html"`,
    },
  });
}
