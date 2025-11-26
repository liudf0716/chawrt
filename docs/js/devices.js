// 设备数据加载和渲染
class DeviceManager {
    constructor() {
        this.devices = [];
        this.deviceListContainer = document.getElementById('device-list');
    }

    async loadDevices() {
        try {
            const response = await fetch('data/devices.json');
            this.devices = await response.json();
            this.renderDeviceList();
        } catch (error) {
            console.error('加载设备列表失败:', error);
            this.showError();
        }
    }

    renderDeviceList() {
        if (!this.deviceListContainer) return;

        const html = this.devices.map(device => `
            <a href="devices/${device.id}.html" class="device-card-link">
                <div class="device-card-simple">
                    <div class="device-info">
                        <h3>${device.name}</h3>
                        <span class="device-chip">${device.chip}</span>
                        <span class="device-status device-status-${device.status}">${this.getStatusText(device.status)}</span>
                    </div>
                    <div class="device-specs-simple">
                        ${Object.entries(device.specs).slice(0, 3).map(([key, value]) => 
                            `<div class="spec-item"><strong>${this.getSpecLabel(key)}:</strong> ${value}</div>`
                        ).join('')}
                    </div>
                    <div class="device-action">
                        查看刷机教程 →
                    </div>
                </div>
            </a>
        `).join('');

        this.deviceListContainer.innerHTML = html;
    }

    getStatusText(status) {
        const statusMap = {
            'stable': '稳定支持',
            'beta': '测试中',
            'experimental': '实验性'
        };
        return statusMap[status] || status;
    }

    getSpecLabel(key) {
        const labelMap = {
            'cpu': 'CPU',
            'ram': '内存',
            'flash': '闪存',
            'wifi': '无线',
            'network': '网络',
            'ports': '端口',
            'expansion': '扩展'
        };
        return labelMap[key] || key;
    }

    showError() {
        if (!this.deviceListContainer) return;
        this.deviceListContainer.innerHTML = `
            <div class="error-message">
                <p>⚠️ 加载设备列表失败，请刷新页面重试。</p>
            </div>
        `;
    }
}

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', () => {
    const deviceManager = new DeviceManager();
    deviceManager.loadDevices();
});
