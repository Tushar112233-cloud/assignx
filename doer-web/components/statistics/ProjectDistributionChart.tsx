"use client";

import React from "react";
import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip, Legend, Label } from "recharts";
import { motion } from "framer-motion";

/**
 * Props for the ProjectDistributionChart component
 */
interface ProjectDistributionChartProps {
  /** Number of completed projects */
  completed: number;
  /** Number of projects in progress */
  inProgress: number;
  /** Number of pending projects */
  pending: number;
  /** Number of projects under revision */
  revision: number;
}

/**
 * Data structure for chart segments
 */
interface ChartData {
  name: string;
  value: number;
  color: string;
  [key: string]: string | number;
}

/**
 * Custom tooltip component for the pie chart
 */
const CustomTooltip = ({ active, payload }: any) => {
  if (active && payload && payload.length) {
    const data = payload[0];
    return (
      <div className="rounded-xl bg-white px-4 py-2 shadow-lg border border-slate-100">
        <p className="text-sm font-medium text-slate-900">{data.name}</p>
        <p className="text-lg font-bold text-slate-700">{data.value}</p>
      </div>
    );
  }
  return null;
};

/**
 * Custom label component to show total in center
 */
const CenterLabel = ({ viewBox, totalProjects }: any) => {
  const { cx, cy } = viewBox;
  return (
    <g>
      <text
        x={cx}
        y={cy - 10}
        textAnchor="middle"
        dominantBaseline="central"
        className="fill-slate-900 text-3xl font-bold"
      >
        {totalProjects}
      </text>
      <text
        x={cx}
        y={cy + 15}
        textAnchor="middle"
        dominantBaseline="central"
        className="fill-slate-500 text-sm font-medium"
      >
        Total Projects
      </text>
    </g>
  );
};

/**
 * Custom legend component with enhanced styling
 */
const CustomLegend = ({ payload }: any) => {
  return (
    <div className="flex flex-wrap justify-center gap-4 mt-4">
      {payload.map((entry: any, index: number) => (
        <motion.div
          key={`legend-${index}`}
          className="flex items-center gap-2"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: index * 0.1 }}
        >
          <div
            className="w-3 h-3 rounded-full"
            style={{ backgroundColor: entry.color }}
          />
          <span className="text-sm font-medium text-slate-700">
            {entry.value}: {entry.payload.value}
          </span>
        </motion.div>
      ))}
    </div>
  );
};

/**
 * ProjectDistributionChart Component
 *
 * Displays a donut chart showing the distribution of projects across different statuses.
 * Features include color-coded segments, center total display, hover interactions, and a legend.
 *
 * @component
 * @example
 * ```tsx
 * <ProjectDistributionChart
 *   completed={45}
 *   inProgress={12}
 *   pending={8}
 *   revision={3}
 * />
 * ```
 */
export const ProjectDistributionChart: React.FC<ProjectDistributionChartProps> = ({
  completed,
  inProgress,
  pending,
  revision,
}) => {
  // Calculate total projects
  const totalProjects = completed + inProgress + pending + revision;

  // Prepare chart data with color assignments
  const chartData: ChartData[] = [
    { name: "Completed", value: completed, color: "#10b981" }, // emerald-500
    { name: "In Progress", value: inProgress, color: "#3b82f6" }, // blue-500
    { name: "Pending", value: pending, color: "#f59e0b" }, // amber-500
    { name: "Revision", value: revision, color: "#f97316" }, // orange-500
  ].filter(item => item.value > 0); // Only show segments with values

  return (
    <motion.div
      className="rounded-[24px] bg-white/85 p-6 shadow-[0_16px_35px_rgba(30,58,138,0.08)]"
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      transition={{ duration: 0.4 }}
    >
      <div className="mb-4">
        <h3 className="text-xl font-bold text-slate-900">Project Distribution</h3>
        <p className="text-sm text-slate-500 mt-1">
          Overview of projects by status
        </p>
      </div>

      <div className="w-full h-[320px]">
        <ResponsiveContainer width="100%" height="100%" minWidth={0} debounce={50}>
          <PieChart>
            <Pie
              data={chartData}
              cx="50%"
              cy="50%"
              innerRadius="60%"
              outerRadius="80%"
              paddingAngle={2}
              dataKey="value"
              animationBegin={0}
              animationDuration={800}
              animationEasing="ease-out"
              label={false}
            >
              {chartData.map((entry, index) => (
                <Cell
                  key={`cell-${index}`}
                  fill={entry.color}
                  className="hover:opacity-80 transition-opacity cursor-pointer"
                  strokeWidth={2}
                  stroke="#fff"
                />
              ))}
              <Label
                content={<CenterLabel totalProjects={totalProjects} />}
                position="center"
              />
            </Pie>
            <Tooltip content={<CustomTooltip />} />
            <Legend content={<CustomLegend />} />
          </PieChart>
        </ResponsiveContainer>
      </div>

      {/* Status breakdown text */}
      <div className="mt-6 pt-4 border-t border-slate-100">
        <div className="grid grid-cols-2 gap-3">
          {chartData.map((item, index) => (
            <motion.div
              key={item.name}
              className="flex items-center justify-between px-3 py-2 rounded-xl bg-slate-50/50"
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: index * 0.05 + 0.3 }}
            >
              <div className="flex items-center gap-2">
                <div
                  className="w-2 h-2 rounded-full"
                  style={{ backgroundColor: item.color }}
                />
                <span className="text-sm font-medium text-slate-600">
                  {item.name}
                </span>
              </div>
              <span className="text-sm font-bold text-slate-900">
                {item.value}
              </span>
            </motion.div>
          ))}
        </div>
      </div>
    </motion.div>
  );
};
