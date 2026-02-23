import { notFound } from "next/navigation";
import { getWalletById } from "@/lib/admin/actions/wallets";
import { format } from "date-fns";
import { Badge } from "@/components/ui/badge";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";

function getTransactionStatusVariant(status: string) {
  switch (status) {
    case "completed":
      return "default" as const;
    case "pending":
    case "processing":
      return "secondary" as const;
    case "failed":
    case "cancelled":
      return "destructive" as const;
    default:
      return "outline" as const;
  }
}

function getTransactionTypeVariant(type: string) {
  switch (type) {
    case "credit":
    case "top_up":
    case "bonus":
    case "project_earning":
      return "default" as const;
    case "debit":
    case "withdrawal":
    case "project_payment":
    case "commission":
      return "secondary" as const;
    case "refund":
    case "reversal":
      return "destructive" as const;
    default:
      return "outline" as const;
  }
}

export const metadata = { title: "Wallet Detail - AssignX Admin" };

export default async function WalletDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  try {
    const { wallet, transactions } = await getWalletById(id);

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const profile = wallet.profile as any;
    const initials = profile?.full_name
      ? profile.full_name
          .split(" ")
          .map((n: string) => n[0])
          .join("")
          .toUpperCase()
      : "?";

    return (
      <div className="flex flex-col gap-4 py-4">
        <div className="px-4 lg:px-6">
          <h1 className="text-2xl font-bold tracking-tight">Wallet Detail</h1>
          <p className="text-muted-foreground">
            View wallet information and transactions
          </p>
        </div>

        <div className="grid gap-4 px-4 lg:px-6 md:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle>Wallet Owner</CardTitle>
            </CardHeader>
            <CardContent className="flex items-center gap-4">
              <Avatar className="size-12">
                <AvatarImage src={profile?.avatar_url} />
                <AvatarFallback>{initials}</AvatarFallback>
              </Avatar>
              <div>
                <p className="font-medium">{profile?.full_name || "Unknown"}</p>
                <p className="text-sm text-muted-foreground">
                  {profile?.email}
                </p>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Balance</CardTitle>
              <CardDescription>Current wallet balance</CardDescription>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold tabular-nums">
                {new Intl.NumberFormat("en-IN", {
                  style: "currency",
                  currency: wallet.currency || "INR",
                }).format(Number(wallet.balance))}
              </p>
              <p className="text-sm text-muted-foreground mt-1">
                Last updated:{" "}
                {format(new Date(wallet.updated_at), "dd MMM yyyy, HH:mm")}
              </p>
            </CardContent>
          </Card>
        </div>

        <div className="px-4 lg:px-6">
          <Card>
            <CardHeader>
              <CardTitle>Recent Transactions</CardTitle>
              <CardDescription>
                Last 50 transactions for this wallet
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="overflow-hidden rounded-lg border">
                <Table>
                  <TableHeader className="bg-muted">
                    <TableRow>
                      <TableHead>Type</TableHead>
                      <TableHead>Amount</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Description</TableHead>
                      <TableHead>Date</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {transactions.length > 0 ? (
                      // eslint-disable-next-line @typescript-eslint/no-explicit-any
                      transactions.map((txn: any) => (
                        <TableRow key={txn.id}>
                          <TableCell>
                            <Badge variant={getTransactionTypeVariant(txn.type)}>
                              {txn.type?.replace(/_/g, " ")}
                            </Badge>
                          </TableCell>
                          <TableCell className="font-medium tabular-nums">
                            {new Intl.NumberFormat("en-IN", {
                              style: "currency",
                              currency: "INR",
                            }).format(Number(txn.amount))}
                          </TableCell>
                          <TableCell>
                            <Badge
                              variant={getTransactionStatusVariant(txn.status)}
                            >
                              {txn.status}
                            </Badge>
                          </TableCell>
                          <TableCell className="max-w-[200px] truncate text-muted-foreground">
                            {txn.description || "-"}
                          </TableCell>
                          <TableCell className="text-muted-foreground">
                            {format(
                              new Date(txn.created_at),
                              "dd MMM yyyy, HH:mm"
                            )}
                          </TableCell>
                        </TableRow>
                      ))
                    ) : (
                      <TableRow>
                        <TableCell
                          colSpan={5}
                          className="h-24 text-center text-muted-foreground"
                        >
                          No transactions found.
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  } catch {
    notFound();
  }
}
