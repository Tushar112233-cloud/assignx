import { NextRequest, NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

/**
 * GET /api/invoices/[projectId]
 * Generate and return invoice PDF for a project
 */
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ projectId: string }> }
) {
  const { projectId } = await params;

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // Fetch project with related data
  const { data: project, error } = await supabase
    .from("projects")
    .select(`
      *,
      subject:subjects (name),
      reference_style:reference_styles (name)
    `)
    .eq("id", projectId)
    .eq("user_id", user.id)
    .single();

  if (error || !project) {
    return NextResponse.json({ error: "Project not found" }, { status: 404 });
  }

  // Fetch user profile
  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name, email, phone")
    .eq("id", user.id)
    .single();

  // Generate invoice HTML
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

  // Calculate amounts (example pricing)
  const baseAmount = project.quoted_price || project.word_count * 0.5 || 999;
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
        <p>${profile?.email || user.email}</p>
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
          <td style="text-align: right;">₹${baseAmount.toLocaleString('en-IN', { minimumFractionDigits: 2 })}</td>
        </tr>
      </tbody>
    </table>

    <div class="totals">
      <div class="totals-row">
        <span>Subtotal</span>
        <span>₹${baseAmount.toLocaleString('en-IN', { minimumFractionDigits: 2 })}</span>
      </div>
      <div class="totals-row">
        <span>GST (18%)</span>
        <span>₹${gst.toLocaleString('en-IN', { minimumFractionDigits: 2 })}</span>
      </div>
      <div class="totals-row total">
        <span>Total</span>
        <span>₹${totalAmount.toLocaleString('en-IN', { minimumFractionDigits: 2 })}</span>
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

  // Return as HTML that can be printed to PDF by browser
  // In production, use a PDF library like puppeteer or jspdf
  return new NextResponse(invoiceHtml, {
    headers: {
      "Content-Type": "text/html",
      "Content-Disposition": `attachment; filename="Invoice_${project.project_number}.html"`,
    },
  });
}
