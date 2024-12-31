// Chart One 

var options1 = {
    series: [{
        data: [25, 66, 41, 89, 63, 25, 44, 12, 36, 9]
    }],
    chart: {
        type: 'line',
        width: 100,
        height: 42,
        sparkline: {
            enabled: true
        }
    },
    colors: ['#dc4135'],
    stroke: {
        show: true,
        curve: 'smooth',
        width: 3
    },
    tooltip: {
        fixed: {
            enabled: false
        },
        x: {
            show: false
        },
        y: {
            title: {
                formatter: function (seriesName) {
                    return ''
                }
            }
        },
        marker: {
            show: false
        }
    }
};

let chartOne = document.getElementById("chart-1");

if (chartOne) {
    let chart1 = new ApexCharts(chartOne, options1);
    chart1.render();
}

// Chart Two 

var options2 = {
    series: [{
        data: [25, 82, 41, 29, 63, 78, 63, 28, 48, 91]
    }],
    chart: {
        type: 'line',
        width: 100,
        height: 42,
        sparkline: {
            enabled: true
        }
    },
    colors: ['#198766'],
    stroke: {
        show: true,
        curve: 'smooth',
        width: 3
    },
    tooltip: {
        fixed: {
            enabled: false
        },
        x: {
            show: false
        },
        y: {
            title: {
                formatter: function (seriesName) {
                    return ''
                }
            }
        },
        marker: {
            show: false
        }
    }
};

let chartTwo = document.getElementById("chart-2");

if (chartTwo) {
    let chart2 = new ApexCharts(chartTwo, options2);
    chart2.render();
}

var visitorsOptions = {
    series: [{
        name: 'Visitors',
        data: [364, 487, 579, 632, 654, 423, 487, 645, 658, 589, 635, 702, 585, 670, 705, 605, 852, 579, 632, 654, 547, 745, 645, 658, 589, 647, 478, 485, 547, 631]
    }],
    chart: {
        id: 'area-datetime',
        type: 'area',
        height: 320,
        zoom: {
            autoScaleYaxis: true
        },
        toolbar: {
            show: false
        }
    },
    labels: ['1 Jan 2022', '2 Jan 2022', '3 Jan 2022', '4 Jan 2022', '5 Jan 2022', '6 Jan 2022', '7 Jan 2022', '8 Jan 2022', '9 Jan 2022', '10 Jan 2022', '11 Jan 2022', '12 Jan 2022', '13 Jan 2022', '14 Jan 2022', '15 Jan 2022', '16 Jan 2022', '17 Jan 2022', '18 Jan 2022', '19 Jan 2022', '20 Jan 2022', '21 Jan 2022', '22 Jan 2022', '23 Jan 2022', '24 Jan 2022', '25 Jan 2022', '26 Jan 2022', '27 Jan 2022', '28 Jan 2022', '29 Jan 2022', '30 Jan 2022'],
    dataLabels: {
        enabled: false
    },
    markers: {
        size: 0,
        style: '',
    },
    xaxis: {
        labels: {
            show: false,
        },
    },
    yaxis: {
        labels: {
            style: {
                colors: ["#8480ae"],
                fontFamily: 'DM Sans, sans-serif',
            },
        },
        title: {
            style: {
                fontSize: '12px',
                fontFamily: 'DM Sans, sans-serif',
            },
        },
    },
    tooltip: {
        theme: 'dark',
        x: {
            show: false
        },
        style: {
            fontSize: '12px',
            fontFamily: 'DM Sans, sans-serif'
        },
    },
    fill: {
        type: 'gradient',
        gradient: {
            shadeIntensity: 1,
            opacityFrom: 0.6,
            opacityTo: 1,
            stops: [0, 100]
        }
    },
};

let chartThree = document.getElementById("chart-timeline");

if (chartThree) {
    let chart = new ApexCharts(chartThree, visitorsOptions);
    chart.render();
}

var priceHistory = {
    series: [{
        name: 'Bitcoin',
        data: [31, 40, 28, 51, 42, 109, 100, 79, 99, 68]
    }, {
        name: 'ETH',
        data: [11, 32, 45, 32, 34, 52, 41, 76, 62, 88]
    }],
    colors: ["#0d6efd", "#0db7f0"],
    chart: {
        height: 300,
        type: 'area',
        zoom: {
            autoScaleYaxis: true
        },
        toolbar: {
            show: false
        }
    },
    dataLabels: {
        enabled: false
    },
    legend: {
        show: true,
        position: 'top',
        fontSize: '14px',
        fontFamily: 'DM Sans, sans-serif',
        fontWeight: 500,
        labels: {
            colors: ["#8480ae"],
        },
    },
    stroke: {
        curve: 'smooth'
    },
    xaxis: {
        type: 'datetime',
        categories: ["2022-09-19T00:00:00.000Z", "2022-09-19T01:00:00.000Z", "2022-09-19T02:00:00.000Z", "2022-09-19T03:00:00.000Z", "2022-09-19T04:00:00.000Z", "2022-09-19T05:00:00.000Z", "2022-09-19T06:00:00.000Z", "2022-09-19T07:00:00.000Z", "2022-09-19T08:00:00.000Z", "2022-09-19T09:00:00.000Z"],
        labels: {
            style: {
                colors: ["#8480ae"],
                fontFamily: 'DM Sans, sans-serif',
            },
        },
        tooltip: {
            enabled: false,
        },
    },
    yaxis: {
        labels: {
            style: {
                colors: ["#8480ae"],
                fontFamily: 'DM Sans, sans-serif',
            },
        },
        title: {
            style: {
                fontSize: '12px',
                fontFamily: 'DM Sans, sans-serif',
            },
        },
        crosshairs: {
            stroke: {
                color: '#8480ae',
            },
        },
    },
    tooltip: {
        theme: 'dark',
        x: {
            format: 'dd/MM/yy HH:mm'
        },
        style: {
            fontSize: '12px',
            fontFamily: 'DM Sans, sans-serif',
        },
    },
    grid: {
        show: true,
        borderColor: '#8480ae',
        position: 'back',
    }
};

let chartFour = document.getElementById("chart-price");

if (chartFour) {
    let priceChart = new ApexCharts(chartFour, priceHistory);
    priceChart.render();
}

// Mengambil data dari backend
const viewData = JSON.parse(document.getElementById('viewData').textContent);
console.log(viewData);  // Cek apakah data diterima dengan benar

if (viewData && viewData.length > 0) {
    // Membuat label waktu dari 00:00 sampai 23:00
    const labels = [];
    for (let hour = 0; hour < 24; hour++) {
        const formattedHour = hour < 10 ? `0${hour}:00` : `${hour}:00`;
        labels.push(formattedHour);
    }

    // Membuat array counts, dan set default nilai 0 untuk setiap jam
    const counts = labels.map(hour => {
        // Mencari data yang sesuai dengan label waktu saat ini
        const dataPoint = viewData.find(row => row.start_time === hour);
        return dataPoint ? dataPoint.row_count : 0; // Jika tidak ada data, return 0
    });

    // Menentukan nilai maksimum untuk sumbu Y
    const maxValue = Math.max(...counts); // Cari nilai tertinggi dalam data
    const roundedMax = Math.ceil(maxValue) * 5; // Bulatkan ke kelipatan 5
    const yAxisMax = roundedMax > 0 ? roundedMax : 5; // Pastikan minimal nilai max adalah 5

    // Konfigurasi grafik menggunakan ApexCharts
    const visitorsOptions = {
        series: [{
            name: 'Total Visit',
            data: counts // Menggunakan array counts yang sudah dibuat
        }],
        chart: {
            type: 'area',
            height: 320,
            zoom: {
                autoScaleYaxis: true
            },
            toolbar: {
                show: false
            }
        },
        dataLabels: {
            enabled: false,
        },
        xaxis: {
            categories: labels, // Label waktu (00:00 - 23:00)
            labels: {
                style: {
                    fontSize: '12px',
                    fontFamily: 'DM Sans, sans-serif',
                }
            }
        },
        yaxis: {
            max: yAxisMax, // Tetapkan nilai maksimum sumbu Y
            tickAmount: 5, // Tetapkan jumlah label menjadi 5
            labels: {
                formatter: function (value) {
                    return Math.round(value); // Menampilkan nilai bulat
                },
                style: {
                    fontSize: '12px',
                    fontFamily: 'DM Sans, sans-serif',
                }
            }
        },
        tooltip: {
            theme: 'dark',
            x: {
                show: true // Menampilkan waktu pada tooltip
            },
            style: {
                fontSize: '12px',
                fontFamily: 'DM Sans, sans-serif'
            }
        },
        fill: {
            type: 'gradient',
            gradient: {
                shadeIntensity: 1,
                opacityFrom: 0.6,
                opacityTo: 1,
                stops: [0, 100]
            }
        }
    };

    // Render grafik menggunakan ApexCharts
    const chartElement = document.getElementById("visitorChart");
    if (chartElement) {
        const chart = new ApexCharts(chartElement, visitorsOptions);
        chart.render();
    }
} else {
    console.log("Data view_data kosong atau tidak valid");
}

// Mengambil data dari backend
const transactionData = JSON.parse(document.getElementById('transactionData').textContent);
console.log(transactionData);  // Cek apakah data diterima dengan benar

if (transactionData && transactionData.length > 0) {
    // Membuat label tanggal dari data yang tersedia
    const labels = transactionData.map(row => row.transaction_date); // Ambil tanggal sebagai label

    // Membuat array untuk total revenue dan profit
    const revenues = transactionData.map(row => row.total_revenue);
    const profits = transactionData.map(row => row.total_profit);

    // Menentukan nilai maksimum untuk sumbu Y
    const maxRevenue = Math.max(...revenues); // Cari nilai tertinggi untuk revenue
    const roundedMax = Math.ceil(maxRevenue / 5) * 5; // Bulatkan ke puluhan terdekat
    const yAxisMax = roundedMax > 0 ? roundedMax : 5; // Pastikan minimal nilai max adalah 10

    // Fungsi untuk memformat angka menjadi format Rupiah
    const formatRupiah = (amount) => {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR'
        }).format(amount);
    };

    // Konfigurasi grafik menggunakan ApexCharts
    const transactionOptions = {
        series: [
            { name: 'Revenue', data: revenues },
            { name: 'Profit', data: profits }
        ],
        chart: {
            type: 'area',
            height: 320,
            zoom: {
                autoScaleYaxis: true
            },
            toolbar: {
                show: false
            }
        },
        dataLabels: {
            enabled: false,
        },
        xaxis: {
            categories: labels, // Label tanggal dari data
            labels: {
                style: {
                    fontSize: '12px',
                    fontFamily: 'DM Sans, sans-serif',
                }
            },
            tickAmount: 7,
        },
        yaxis: {
            max: yAxisMax, // Tetapkan nilai maksimum sumbu Y
            min: 0,
            tickAmount: 5, // Tetapkan jumlah label menjadi 5
            labels: {
                formatter: function (value) {
                    return formatRupiah(value); // Menampilkan nilai dalam format Rupiah
                },
                style: {
                    fontSize: '12px',
                    fontFamily: 'DM Sans, sans-serif',
                }
            }
        },
        tooltip: {
            theme: 'dark',
            x: {
                show: true // Menampilkan tanggal pada tooltip
            },
            style: {
                fontSize: '12px',
                fontFamily: 'DM Sans, sans-serif'
            }
        },
        fill: {
            type: 'gradient',
            gradient: {
                shadeIntensity: 1,
                opacityFrom: 0.6,
                opacityTo: 1,
                stops: [0, 100]
            }
        }
    };

    // Render grafik menggunakan ApexCharts
    const chartElement = document.getElementById("transactionChart");
    if (chartElement) {
        const chart = new ApexCharts(chartElement, transactionOptions);
        chart.render();
    }
} else {
    console.log("Data transaction_data kosong atau tidak valid");
}
