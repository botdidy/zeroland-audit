"use client"

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { ExternalLink, Copy } from "lucide-react"

export default function ContractsTracker() {
  const contracts = [
    {
      name: "ZeroLend Pool",
      address: "0xb5eb2c8D62f59D73488D8C8f567654fE6F0CAf1",
      type: "Main Lending Pool",
      network: "Linea",
    },
    {
      name: "Pool Configurator",
      address: "0x39e1E77888D7e5B8A8C5e3f89B9D1DdaA5516D48",
      type: "Configuration",
      network: "Linea",
    },
    {
      name: "Oracle",
      address: "0x86b4dC5F2cB7D8857e207A5E29e997B9333C53d0",
      type: "Price Oracle",
      network: "Linea",
    },
  ]

  const copyAddress = (address: string) => {
    navigator.clipboard.writeText(address)
  }

  return (
    <Card className="w-full">
      <CardHeader>
        <CardTitle>ZeroLend Contract Tracker</CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Contract</TableHead>
              <TableHead>Address</TableHead>
              <TableHead>Type</TableHead>
              <TableHead>Network</TableHead>
              <TableHead>Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {contracts.map((contract) => (
              <TableRow key={contract.address}>
                <TableCell>{contract.name}</TableCell>
                <TableCell className="font-mono">
                  {contract.address.slice(0, 6)}...{contract.address.slice(-4)}
                </TableCell>
                <TableCell>{contract.type}</TableCell>
                <TableCell>{contract.network}</TableCell>
                <TableCell>
                  <div className="flex space-x-2">
                    <Button variant="outline" size="icon" onClick={() => copyAddress(contract.address)}>
                      <Copy className="h-4 w-4" />
                    </Button>
                    <Button
                      variant="outline"
                      size="icon"
                      onClick={() => window.open(`https://lineascan.build/address/${contract.address}`, "_blank")}
                    >
                      <ExternalLink className="h-4 w-4" />
                    </Button>
                  </div>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  )
}

