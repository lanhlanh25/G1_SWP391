package controller;

import dal.BestSellingProductStatisticsDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.WeekFields;
import java.util.List;
import java.util.Locale;
import model.BestSellingProductStat;

public class ManagerViewBestSellingProductStatistics {

    public static void handle(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String periodType = getOrDefault(request.getParameter("periodType"), "month");
        String sortOrder = getOrDefault(request.getParameter("sortOrder"), "DESC").toUpperCase();
        int topN = parseIntOrDefault(request.getParameter("topN"), 10);

        if (topN != 10 && topN != 20 && topN != 50 && topN != 100) {
            topN = 10;
        }

        LocalDate fromDate;
        LocalDate toDate;

        try {
            LocalDate[] range = resolveDateRange(request, periodType);
            fromDate = range[0];
            toDate = range[1];
        } catch (Exception e) {
            LocalDate now = LocalDate.now();
            fromDate = now.withDayOfMonth(1);
            toDate = now.withDayOfMonth(now.lengthOfMonth());
            request.setAttribute("err", "Invalid filter value. System used current month by default.");
            periodType = "month";
        }

        BestSellingProductStatisticsDAO dao = new BestSellingProductStatisticsDAO();

        try {
            List<BestSellingProductStat> stats = dao.getBestSellingProducts(
                    Date.valueOf(fromDate),
                    Date.valueOf(toDate),
                    topN,
                    sortOrder
            );

            BestSellingProductStat bestProduct = dao.getBestProduct(
                    Date.valueOf(fromDate),
                    Date.valueOf(toDate)
            );

            int totalUnitsSold = dao.getTotalUnitsSold(
                    Date.valueOf(fromDate),
                    Date.valueOf(toDate)
            );

            request.setAttribute("stats", stats);
            request.setAttribute("bestProduct", bestProduct);
            request.setAttribute("totalUnitsSold", totalUnitsSold);

            request.setAttribute("periodType", periodType);
            request.setAttribute("sortOrder", sortOrder);
            request.setAttribute("topN", topN);
            request.setAttribute("fromDate", fromDate);
            request.setAttribute("toDate", toDate);

            request.setAttribute("year", request.getParameter("year"));
            request.setAttribute("month", request.getParameter("month"));
            request.setAttribute("quarter", request.getParameter("quarter"));
            request.setAttribute("week", request.getParameter("week"));
            request.setAttribute("from", request.getParameter("from"));
            request.setAttribute("to", request.getParameter("to"));

        } catch (Exception e) {
            throw new ServletException("Load best-selling product statistics failed", e);
        }
    }

    private static String getOrDefault(String value, String defaultValue) {
        return (value == null || value.isBlank()) ? defaultValue : value.trim();
    }

    private static int parseIntOrDefault(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private static LocalDate[] resolveDateRange(HttpServletRequest request, String periodType) {
        LocalDate now = LocalDate.now();

        switch (periodType.toLowerCase()) {
            case "week": {
                int year = parseIntOrDefault(request.getParameter("year"), now.getYear());
                int week = parseIntOrDefault(
                        request.getParameter("week"),
                        now.get(WeekFields.of(Locale.getDefault()).weekOfWeekBasedYear())
                );

                WeekFields wf = WeekFields.of(Locale.getDefault());
                LocalDate firstDay = LocalDate.of(year, 1, 4)
                        .with(wf.weekOfWeekBasedYear(), week)
                        .with(DayOfWeek.MONDAY);

                LocalDate lastDay = firstDay.plusDays(6);
                return new LocalDate[]{firstDay, lastDay};
            }

            case "month": {
                int year = parseIntOrDefault(request.getParameter("year"), now.getYear());
                int month = parseIntOrDefault(request.getParameter("month"), now.getMonthValue());
                YearMonth ym = YearMonth.of(year, month);
                return new LocalDate[]{ym.atDay(1), ym.atEndOfMonth()};
            }

            case "quarter": {
                int year = parseIntOrDefault(request.getParameter("year"), now.getYear());
                int quarter = parseIntOrDefault(request.getParameter("quarter"), 1);

                int startMonth;
                switch (quarter) {
                    case 1:
                        startMonth = 1;
                        break;
                    case 2:
                        startMonth = 4;
                        break;
                    case 3:
                        startMonth = 7;
                        break;
                    case 4:
                        startMonth = 10;
                        break;
                    default:
                        startMonth = 1;
                        break;
                }

                LocalDate from = LocalDate.of(year, startMonth, 1);
                LocalDate to = from.plusMonths(2).withDayOfMonth(from.plusMonths(2).lengthOfMonth());
                return new LocalDate[]{from, to};
            }

            case "year": {
                int year = parseIntOrDefault(request.getParameter("year"), now.getYear());
                return new LocalDate[]{
                    LocalDate.of(year, 1, 1),
                    LocalDate.of(year, 12, 31)
                };
            }

            case "custom": {
                String fromRaw = request.getParameter("from");
                String toRaw = request.getParameter("to");

                if (fromRaw == null || fromRaw.isBlank() || toRaw == null || toRaw.isBlank()) {
                    throw new IllegalArgumentException("Missing custom date range");
                }

                LocalDate from = LocalDate.parse(fromRaw.trim());
                LocalDate to = LocalDate.parse(toRaw.trim());

                if (to.isBefore(from)) {
                    throw new IllegalArgumentException("To date must not be before from date");
                }

                return new LocalDate[]{from, to};
            }

            default: {
                return new LocalDate[]{
                    now.withDayOfMonth(1),
                    now.withDayOfMonth(now.lengthOfMonth())
                };
            }
        }
    }
}
