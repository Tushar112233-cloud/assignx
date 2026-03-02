import { getFinancialSummary, getTransactions } from "@/lib/admin/actions/wallets";
import { FinancialSummaryCards } from "@/components/admin/wallets/financial-summary-cards";
import { TransactionsDataTable } from "@/components/admin/wallets/transactions-data-table";
import { RevenueChart } from "@/components/admin/wallets/revenue-chart";

export const metadata = { title: "Wallets & Payments - AssignX Admin" };

interface TransactionRecord {
  created_at: string;
  transaction_type: string;
  status: string;
  amount: number | string;
}

function buildRevenueChartData(
  txns: TransactionRecord[]
): { date: string; revenue: number; refunds: number }[] {
  const grouped: Record<string, { revenue: number; refunds: number }> = {};

  txns.forEach((txn) => {
    const date = new Date(txn.created_at).toISOString().split("T")[0];
    if (!grouped[date]) grouped[date] = { revenue: 0, refunds: 0 };
    if (txn.transaction_type === "project_payment" && txn.status === "completed") {
      grouped[date].revenue += Number(txn.amount);
    }
    if (txn.transaction_type === "refund" && txn.status === "completed") {
      grouped[date].refunds += Number(txn.amount);
    }
  });

  return Object.entries(grouped)
    .map(([date, vals]) => ({ date, ...vals }))
    .sort((a, b) => a.date.localeCompare(b.date));
}

export default async function WalletsPage({
  searchParams,
}: {
  searchParams: Promise<{
    type?: string;
    status?: string;
    page?: string;
  }>;
}) {
  const params = await searchParams;

  const [summary, transactionsData, chartTransactions] = await Promise.all([
    getFinancialSummary("30d").catch(() => ({
      total_revenue: 0,
      refunds: 0,
      payouts: 0,
      platform_fees: 0,
      net_revenue: 0,
      avg_project_value: 0,
    })),
    getTransactions({
      type: params.type,
      status: params.status,
      page: parseInt(params.page || "1"),
      perPage: 20,
    }).catch(() => ({ data: [], total: 0, page: 1, total_pages: 1 })),
    getTransactions({
      dateFrom: new Date(Date.now() - 90 * 86400000).toISOString(),
      perPage: 1000,
    }).catch(() => ({ data: [] })),
  ]);

  const chartData = buildRevenueChartData(
    (chartTransactions?.data || []) as TransactionRecord[]
  );

  return (
    <div className="flex flex-col gap-4 py-4">
      <div className="px-4 lg:px-6">
        <h1 className="text-2xl font-bold tracking-tight">
          Wallets & Payments
        </h1>
        <p className="text-muted-foreground">
          Financial overview and transaction management
        </p>
      </div>
      <FinancialSummaryCards summary={summary} />
      <div className="px-4 lg:px-6">
        <RevenueChart chartData={chartData} />
      </div>
      <TransactionsDataTable
        data={transactionsData.data || []}
        total={transactionsData.total || 0}
        page={transactionsData.page || 1}
        totalPages={transactionsData.total_pages || 1}
      />
    </div>
  );
}
