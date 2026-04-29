import React, { useState, useEffect } from 'react'
import { 
  LayoutDashboard, 
  Users, 
  Settings, 
  Bell, 
  Search, 
  TrendingUp, 
  UserCheck, 
  Clock, 
  Shield,
  Grid,
  CheckCircle,
  ArrowUpRight,
  ChevronRight,
  LogOut,
  MoreVertical,
  Trash2,
  Leaf,
  CreditCard,
  Briefcase
} from 'lucide-react'
import { 
  LineChart, 
  Line, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  AreaChart,
  Area
} from 'recharts'

const MOCK_DATA = [
  { name: 'Mon', users: 400 },
  { name: 'Tue', users: 300 },
  { name: 'Wed', users: 200 },
  { name: 'Thu', users: 278 },
  { name: 'Fri', users: 189 },
  { name: 'Sat', users: 239 },
  { name: 'Sun', users: 349 },
]

function App() {
  const [activeTab, setActiveTab] = useState('dashboard')
  const [users, setUsers] = useState([])
  const [stats, setStats] = useState({ total: 0, approved: 0, pending: 0, growth: '0%' })
  const [loading, setLoading] = useState(true)
  const [apiUrl, setApiUrl] = useState(localStorage.getItem('admin_api_url') || 'http://localhost:8000/api')
  const [bankerId, setBankerId] = useState(localStorage.getItem('admin_banker_id') || '1')
  const [connectionStatus, setConnectionStatus] = useState('checking')
  
  // New Management State
  const [searchQuery, setSearchQuery] = useState('')
  const [statusFilter, setStatusFilter] = useState('All')
  const [serviceFilter, setServiceFilter] = useState('All')
  const [activities, setActivities] = useState([
    { id: 1, type: 'registration', text: 'New Farmer registered from Amritsar', time: '2 mins ago' },
    { id: 2, type: 'approval', text: 'Loan approved for Rahul Sharma', time: '1 hour ago' },
    { id: 3, type: 'system', text: 'Daily database backup completed', time: '4 hours ago' }
  ])

  // Modal State
  const [isEditModalOpen, setIsEditModalOpen] = useState(false)
  const [selectedUser, setSelectedUser] = useState(null)

  useEffect(() => {
    fetchData()
  }, [apiUrl, bankerId])

  const fetchData = async () => {
    try {
      setLoading(true)
      setConnectionStatus('checking')
      
      const statsRes = await fetch(`${apiUrl}/dashboard-stats?bank_user_id=${bankerId}`)
      if (statsRes.ok) {
        const statsData = await statsRes.json()
        setStats({
          total: parseInt(statsData.users || '0'),
          approved: parseInt(statsData.approved || '0'),
          pending: (parseInt(statsData.registrations || '0') - parseInt(statsData.approved || '0')),
          growth: '+12%'
        })
      }

      const usersRes = await fetch(`${apiUrl}/leads?bank_user_id=${bankerId}`)
      if (usersRes.ok) {
        const leadsData = await usersRes.json()
        const mappedUsers = leadsData.map(lead => ({
          ...lead,
          service: lead.loan_type || "N/A",
          amount: lead.amount && !isNaN(parseFloat(lead.amount)) 
            ? `₹${parseFloat(lead.amount).toLocaleString()}` 
            : (lead.amount || "N/A"),
          location: `${lead.city || ''}, ${lead.state || ''}`.trim() || "N/A",
          date: lead.created_at ? new Date(lead.created_at).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' }) : "Today"
        }))
        setUsers(mappedUsers)
        setConnectionStatus('online')
      } else {
        throw new Error('Backend not reachable')
      }
    } catch (error) {
      console.warn("Real data fetch failed:", error)
      setConnectionStatus('offline')
      setUsers([
        { id: 1, name: "Rahul Sharma", mobile: "9876543210", service: "Farmers", amount: "₹50,000", location: "Delhi", status: "Pending", date: "28 Apr" },
        { id: 2, name: "Priya Patel", mobile: "8765432109", service: "Business", amount: "₹2,00,000", location: "Mumbai", status: "Approved", date: "27 Apr" },
        { id: 3, name: "Suresh Meena", mobile: "7654321098", service: "Student", amount: "₹20,000", location: "Jaipur", status: "Approved", date: "27 Apr" },
      ])
      setStats({ total: 12482, approved: 8200, pending: 154, growth: '+12.5%' })
    } finally {
      setLoading(false)
    }
  }

  const handleUpdateUser = async (updatedData) => {
    try {
      setUsers(prev => prev.map(u => u.id === updatedData.id ? updatedData : u))
      setIsEditModalOpen(false)
      setActivities(prev => [{ id: Date.now(), type: 'system', text: `Admin updated user: ${updatedData.name}`, time: 'Just now' }, ...prev])

      const res = await fetch(`${apiUrl}/leads/update-status`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          id: updatedData.id,
          status: updatedData.status,
          bank_user_id: bankerId,
          table: updatedData.table_name
        })
      })
      if (!res.ok) throw new Error('Update failed')
      fetchData()
    } catch (err) {
      console.error(err)
      alert("Failed to update user. Please check your backend connection.")
    }
  }

  const handleDeleteUser = async (id, name, tableName) => {
    if (!window.confirm(`Are you sure you want to permanently delete lead for ${name}?`)) return;
    
    try {
      setUsers(prev => prev.filter(u => u.id !== id));
      setActivities(prev => [{ id: Date.now(), type: 'system', text: `Admin deleted lead: ${name}`, time: 'Just now' }, ...prev])

      const res = await fetch(`${apiUrl}/leads/delete`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          id,
          table: tableName
        })
      });

      if (!res.ok) throw new Error('Delete failed');
      fetchData();
    } catch (err) {
      console.error(err);
      alert("Failed to delete user. Please check your backend connection.");
    }
  }

  const exportToCSV = () => {
    if (users.length === 0) return alert("No data to export");
    const headers = ["ID", "Name", "Mobile", "Service", "Amount", "Location", "Status", "Date"];
    const csvRows = [
      headers.join(','),
      ...users.map(u => [u.id, `"${u.name}"`, u.mobile, u.service, u.amount, `"${u.location}"`, u.status, u.date].join(','))
    ];
    const blob = new Blob([csvRows.join('\n')], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `management_data_${new Date().toISOString().split('T')[0]}.csv`;
    a.click();
  }

  const filteredUsers = users.filter(u => {
    const matchesSearch = u.name.toLowerCase().includes(searchQuery.toLowerCase()) || u.mobile.includes(searchQuery);
    const matchesStatus = statusFilter === 'All' || u.status === statusFilter;
    const matchesService = serviceFilter === 'All' || u.service === serviceFilter;
    return matchesSearch && matchesStatus && matchesService;
  });

  const serviceStats = users.reduce((acc, u) => {
    acc[u.service] = (acc[u.service] || 0) + 1;
    return acc;
  }, {});

  return (
    <div className="app-container" style={{ display: 'flex', minHeight: '100vh' }}>
      {/* Sidebar */}
      <aside style={{ 
        width: '280px', 
        backgroundColor: 'rgba(255, 255, 255, 0.02)', 
        borderRight: '1px solid var(--border)',
        padding: '32px 24px',
        display: 'flex',
        flexDirection: 'column',
        backdropFilter: 'blur(20px)'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '48px', padding: '0 8px' }}>
          <div style={{ 
            width: '40px', 
            height: '40px', 
            borderRadius: '12px', 
            background: 'linear-gradient(135deg, var(--primary), #fdb913)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            boxShadow: '0 8px 16px rgba(242, 101, 34, 0.3)'
          }}>
            <Shield size={24} color="white" />
          </div>
          <div>
            <h1 style={{ fontSize: '18px', fontWeight: '800', letterSpacing: '-0.5px' }}>DIGITAL BHARAT</h1>
            <p style={{ fontSize: '10px', color: 'var(--text-muted)', fontWeight: '600', letterSpacing: '1px' }}>ADMIN CONSOLE</p>
          </div>
        </div>

        <nav style={{ flex: 1 }}>
          <SidebarLink icon={<LayoutDashboard size={20} />} label="Command Center" active={activeTab === 'dashboard'} onClick={() => setActiveTab('dashboard')} />
          
          <div style={{ marginTop: '32px', marginBottom: '12px', padding: '0 8px', fontSize: '10px', color: 'var(--text-muted)', fontWeight: '700', letterSpacing: '1px' }}>SERVICE LEADS</div>
          
          <SidebarLink 
            icon={<Leaf size={20} />} 
            label="Crop Registry" 
            active={activeTab === 'users' && serviceFilter === 'Crop Registration'} 
            onClick={() => {
              setServiceFilter('Crop Registration');
              setActiveTab('users');
            }} 
          />
          
          <SidebarLink 
            icon={<CreditCard size={20} />} 
            label="Loan Center" 
            active={activeTab === 'users' && (serviceFilter.includes('Loan') && serviceFilter !== 'Crop Registration')} 
            onClick={() => {
              setServiceFilter('Farmer Loan'); // Default to Farmer Loan in the hub
              setActiveTab('users');
            }} 
          />
          
          <SidebarLink 
            icon={<Briefcase size={20} />} 
            label="Job Postings" 
            active={activeTab === 'users' && serviceFilter === 'Job Posting'} 
            onClick={() => {
              setServiceFilter('Job Posting');
              setActiveTab('users');
            }} 
          />
          
          <SidebarLink 
            icon={<UserCheck size={20} />} 
            label="Internship Apps" 
            active={activeTab === 'users' && serviceFilter === 'Job Application'} 
            onClick={() => {
              setServiceFilter('Job Application');
              setActiveTab('users');
            }} 
          />

          <div style={{ marginTop: '32px', marginBottom: '12px', padding: '0 8px', fontSize: '10px', color: 'var(--text-muted)', fontWeight: '700', letterSpacing: '1px' }}>MANAGEMENT</div>
          
          <SidebarLink icon={<Grid size={20} />} label="Service Engine" active={activeTab === 'services'} onClick={() => setActiveTab('services')} />
          <SidebarLink icon={<Bell size={20} />} label="Broadcasts" active={activeTab === 'notifications'} onClick={() => setActiveTab('notifications')} />
          <SidebarLink icon={<Settings size={20} />} label="Configuration" active={activeTab === 'settings'} onClick={() => setActiveTab('settings')} />
        </nav>

        <div className="glass-card" style={{ padding: '16px', marginTop: 'auto' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{ width: '8px', height: '8px', borderRadius: '50%', backgroundColor: connectionStatus === 'online' ? '#22c55e' : '#ef4444' }}></div>
            <p style={{ fontSize: '12px', fontWeight: '600' }}>System: {connectionStatus.toUpperCase()}</p>
          </div>
          <p style={{ fontSize: '10px', color: 'var(--text-muted)', marginTop: '4px' }}>Banker ID: {bankerId}</p>
        </div>
      </aside>

      {/* Main Content */}
      <main style={{ flex: 1, padding: '40px 60px', overflowY: 'auto', backgroundColor: 'var(--bg)' }}>
        <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '40px' }}>
          <div>
            <h2 style={{ fontSize: '28px', fontWeight: '700', marginBottom: '4px' }}>
              {activeTab === 'dashboard' && "System Overview"}
              {activeTab === 'users' && "User Management"}
              {activeTab === 'services' && "Service Optimization"}
              {activeTab === 'settings' && "System Configuration"}
            </h2>
            <p style={{ color: 'var(--text-muted)' }}>Real-time synchronization with Digital Bharat Nodes</p>
          </div>
          <div style={{ display: 'flex', gap: '16px' }}>
            <div className="glass-card" style={{ padding: '8px 16px', display: 'flex', alignItems: 'center', gap: '12px' }}>
              <Search size={18} color="var(--text-muted)" />
              <input 
                type="text" 
                placeholder="Search database..." 
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{ background: 'none', border: 'none', color: 'white', outline: 'none', width: '200px' }} 
              />
            </div>
            <button className="btn-primary" style={{ padding: '0 20px', borderRadius: '12px' }}>Refresh</button>
          </div>
        </header>

        {activeTab === 'dashboard' && (
          <>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '24px', marginBottom: '40px' }}>
              <StatCard icon={<Users color="#3b82f6" />} label="Total Registrations" value={stats.total.toLocaleString()} trend={stats.growth} />
              <StatCard icon={<CheckCircle color="#22c55e" />} label="Approved Profiles" value={stats.approved.toLocaleString()} trend="+8.2%" />
              <StatCard icon={<Clock color="#f59e0b" />} label="Pending Verification" value={stats.pending.toLocaleString()} trend="-2.4%" />
              <StatCard icon={<ArrowUpRight color="#a855f7" />} label="System Uptime" value="99.9%" trend="Stable" />
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' }}>
              <div className="glass-card" style={{ padding: '32px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
                  <h3 style={{ fontSize: '18px', fontWeight: '600' }}>Recent Network Activity</h3>
                  <button onClick={() => setActiveTab('users')} style={{ color: 'var(--primary)', background: 'none', border: 'none', fontWeight: '600', cursor: 'pointer' }}>View All</button>
                </div>
                <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                  <thead>
                    <tr style={{ borderBottom: '1px solid var(--border)', textAlign: 'left' }}>
                      <th style={{ padding: '16px', color: 'var(--text-muted)', fontWeight: '500', fontSize: '14px' }}>USER</th>
                      <th style={{ padding: '16px', color: 'var(--text-muted)', fontWeight: '500', fontSize: '14px' }}>SERVICE</th>
                      <th style={{ padding: '16px', color: 'var(--text-muted)', fontWeight: '500', fontSize: '14px' }}>AMOUNT</th>
                      <th style={{ padding: '16px', color: 'var(--text-muted)', fontWeight: '500', fontSize: '14px' }}>STATUS</th>
                      <th style={{ padding: '16px' }}></th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.slice(0, 5).map((user, idx) => (
                      <UserRow 
                        key={user.id || idx}
                        name={user.name} 
                        mobile={user.mobile}
                        service={user.service}
                        amount={user.amount}
                        date={user.date || "Today"} 
                        status={user.status || "Pending"} 
                      />
                    ))}
                  </tbody>
                </table>
              </div>

              <div className="glass-card" style={{ padding: '32px' }}>
                <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '24px' }}>Live System Feed</h3>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                  {activities.map(activity => (
                    <div key={activity.id} style={{ display: 'flex', gap: '16px' }}>
                      <div style={{ 
                        width: '32px', 
                        height: '32px', 
                        borderRadius: '8px', 
                        background: 'rgba(255,255,255,0.05)', 
                        display: 'flex', 
                        alignItems: 'center', 
                        justifyContent: 'center',
                        flexShrink: 0
                      }}>
                        {activity.type === 'registration' && <Users size={16} color="var(--primary)" />}
                        {activity.type === 'approval' && <CheckCircle size={16} color="#22c55e" />}
                        {activity.type === 'system' && <Shield size={16} color="#3b82f6" />}
                      </div>
                      <div>
                        <p style={{ fontSize: '13px', fontWeight: '500' }}>{activity.text}</p>
                        <p style={{ fontSize: '11px', color: 'var(--text-muted)' }}>{activity.time}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </>
        )}

        {activeTab === 'users' && (
          <div className="glass-card" style={{ padding: '32px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                <h3 style={{ fontSize: '18px', fontWeight: '600' }}>User Registry ({filteredUsers.length})</h3>
                <select 
                  value={serviceFilter}
                  onChange={(e) => setServiceFilter(e.target.value)}
                  style={{ background: 'rgba(255,255,255,0.05)', color: 'white', border: '1px solid var(--border)', padding: '4px 12px', borderRadius: '8px', outline: 'none' }}
                >
                  <option value="All">All Services</option>
                  {Object.keys(serviceStats).map(s => (
                    <option key={s} value={s}>{s}</option>
                  ))}
                </select>
                <select 
                  value={statusFilter}
                  onChange={(e) => setStatusFilter(e.target.value)}
                  style={{ background: 'rgba(255,255,255,0.05)', color: 'white', border: '1px solid var(--border)', padding: '4px 12px', borderRadius: '8px', outline: 'none' }}
                >
                  <option value="All">All Status</option>
                  <option value="Pending">Pending</option>
                  <option value="Approved">Approved</option>
                  <option value="Suspended">Suspended</option>
                </select>
              </div>
              <div style={{ display: 'flex', gap: '12px' }}>
                <button 
                  onClick={exportToCSV}
                  className="btn-primary" 
                  style={{ padding: '8px 16px', fontSize: '14px' }}
                >
                  Export Data
                </button>
              </div>
            </div>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr style={{ borderBottom: '1px solid var(--border)', textAlign: 'left' }}>
                  <th style={{ padding: '16px', color: 'var(--text-muted)', fontWeight: '500', fontSize: '14px' }}>USER</th>
                  <th style={{ padding: '16px', color: 'var(--text-muted)', fontWeight: '500', fontSize: '14px' }}>SERVICE</th>
                  <th style={{ padding: '16px', color: 'var(--text-muted)', fontWeight: '500', fontSize: '14px' }}>LOCATION</th>
                  <th style={{ padding: '16px', color: 'var(--text-muted)', fontWeight: '500', fontSize: '14px' }}>STATUS</th>
                  <th style={{ padding: '16px' }}>ACTIONS</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((user, idx) => (
                  <UserManageRow 
                    key={user.id || idx}
                    user={user}
                    onEdit={(u) => {
                      setSelectedUser(u);
                      setIsEditModalOpen(true);
                    }}
                    onApprove={(id) => handleUpdateUser({...user, id, status: 'Approved'})}
                    onDelete={handleDeleteUser}
                  />
                ))}
              </tbody>
            </table>
          </div>
        )}

        {activeTab === 'services' && (
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '24px' }}>
            {Object.entries(serviceStats).map(([name, count]) => (
              <div key={name} className="glass-card" style={{ padding: '32px' }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '24px' }}>
                  <div style={{ width: '48px', height: '48px', borderRadius: '12px', background: 'rgba(255,255,255,0.05)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <Grid size={24} color="var(--primary)" />
                  </div>
                  <span style={{ padding: '4px 12px', background: 'rgba(34, 197, 94, 0.1)', color: '#22c55e', borderRadius: '20px', fontSize: '12px', fontWeight: '600' }}>Active</span>
                </div>
                <h3 style={{ fontSize: '20px', fontWeight: '700', marginBottom: '8px' }}>{name}</h3>
                <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginBottom: '24px' }}>Manage all {name} registration forms and criteria.</p>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div>
                    <p style={{ fontSize: '24px', fontWeight: '700' }}>{count}</p>
                    <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>Submissions</p>
                  </div>
                  <button 
                    className="btn-primary" 
                    style={{ padding: '8px 16px', fontSize: '13px' }}
                    onClick={() => {
                      setServiceFilter(name);
                      setActiveTab('users');
                    }}
                  >
                    Manage
                  </button>
                </div>
              </div>
            ))}
            <div className="glass-card" style={{ padding: '32px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', borderStyle: 'dashed', borderColor: 'rgba(255,255,255,0.1)' }}>
              <div style={{ width: '48px', height: '48px', borderRadius: '50%', backgroundColor: 'rgba(255,255,255,0.05)', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '16px' }}>
                <span style={{ fontSize: '24px' }}>+</span>
              </div>
              <p style={{ fontWeight: '600' }}>Add New Service</p>
            </div>
          </div>
        )}

        {activeTab === 'settings' && (
          <div style={{ maxWidth: '600px' }}>
            <div className="glass-card" style={{ padding: '32px', marginBottom: '24px' }}>
              <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '24px' }}>API Configuration</h3>
              <div style={{ marginBottom: '20px' }}>
                <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '8px' }}>Backend API URL</p>
                <input 
                  type="text" 
                  value={apiUrl} 
                  onChange={(e) => setApiUrl(e.target.value)}
                  placeholder="http://localhost:8000/api"
                  style={{ 
                    width: '100%',
                    background: 'rgba(255,255,255,0.05)', 
                    border: '1px solid var(--border)', 
                    color: 'white', 
                    padding: '10px 16px', 
                    borderRadius: '12px',
                    outline: 'none'
                  }} 
                />
              </div>
              <div style={{ marginBottom: '24px' }}>
                <p style={{ fontSize: '14px', color: 'var(--text-muted)', marginBottom: '8px' }}>Banker Profile ID</p>
                <input 
                  type="text" 
                  value={bankerId} 
                  onChange={(e) => setBankerId(e.target.value)}
                  placeholder="e.g. 1"
                  style={{ 
                    width: '100%',
                    background: 'rgba(255,255,255,0.05)', 
                    border: '1px solid var(--border)', 
                    color: 'white', 
                    padding: '10px 16px', 
                    borderRadius: '12px',
                    outline: 'none'
                  }} 
                />
              </div>
              <button 
                onClick={() => handleApiChange(apiUrl, bankerId)}
                className="btn-primary" 
                style={{ width: '100%', padding: '12px' }}
              >
                Save & Refresh Connection
              </button>
            </div>
            <div className="glass-card" style={{ padding: '32px', marginBottom: '24px' }}>
              <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '24px' }}>General Settings</h3>
              <SettingItem label="Portal Maintenance Mode" type="toggle" />
              <SettingItem label="Allow New Registrations" type="toggle" checked />
              <SettingItem label="Admin Notifications" type="toggle" checked />
            </div>
            <div className="glass-card" style={{ padding: '32px' }}>
              <h3 style={{ fontSize: '18px', fontWeight: '600', marginBottom: '24px' }}>Security</h3>
              <button className="glass-card" style={{ width: '100%', padding: '12px', textAlign: 'left', borderRadius: '12px', marginBottom: '12px' }}>Change Admin Password</button>
              <button className="glass-card" style={{ width: '100%', padding: '12px', textAlign: 'left', borderRadius: '12px' }}>Two-Factor Authentication</button>
            </div>
          </div>
        )}
      </main>

      {/* Edit Modal */}
      {isEditModalOpen && selectedUser && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          backgroundColor: 'rgba(0,0,0,0.8)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 1000,
          backdropFilter: 'blur(8px)'
        }}>
          <div className="glass-card" style={{ width: '600px', maxHeight: '90vh', overflowY: 'auto', padding: '40px', position: 'relative' }}>
            <h3 style={{ fontSize: '24px', fontWeight: '700', marginBottom: '8px' }}>User Profile & Edit</h3>
            <p style={{ color: 'var(--text-muted)', marginBottom: '32px' }}>Comprehensive details for {selectedUser.name}</p>
            
            <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                <ModalInput label="Full Name" value={selectedUser.name} onChange={(val) => setSelectedUser({...selectedUser, name: val})} />
                <ModalInput label="Account Status" value={selectedUser.status} isSelect={true} options={['Pending', 'Approved', 'Suspended']} onChange={(val) => setSelectedUser({...selectedUser, status: val})} />
              </div>

              <div style={{ marginTop: '20px' }}>
                <h4 style={{ fontSize: '14px', fontWeight: '600', color: 'var(--primary)', marginBottom: '16px', borderBottom: '1px solid var(--border)', paddingBottom: '8px' }}>FULL PROFILE INFORMATION</h4>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                  {Object.entries(selectedUser).map(([key, value]) => {
                    if (['id', 'name', 'status', 'date'].includes(key)) return null;
                    return (
                      <div key={key} style={{ padding: '12px', background: 'rgba(255,255,255,0.03)', borderRadius: '8px', border: '1px solid var(--border)' }}>
                        <p style={{ fontSize: '11px', color: 'var(--text-muted)', textTransform: 'uppercase', marginBottom: '4px' }}>{key.replace('_', ' ')}</p>
                        <p style={{ fontSize: '13px', fontWeight: '500' }}>{value || 'N/A'}</p>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>

            <div style={{ display: 'flex', gap: '16px', marginTop: '40px' }}>
              <button 
                onClick={() => setIsEditModalOpen(false)}
                style={{ flex: 1, padding: '12px', background: 'rgba(255,255,255,0.05)', border: 'none', color: 'white', borderRadius: '12px', cursor: 'pointer' }}
              >
                Close
              </button>
              <button 
                onClick={() => handleUpdateUser(selectedUser)}
                className="btn-primary" 
                style={{ flex: 1, padding: '12px' }}
              >
                Save Changes
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

function ModalInput({ label, value, onChange, isSelect, options }) {
  return (
    <div>
      <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '8px' }}>{label}</p>
      {isSelect ? (
        <select 
          value={value} 
          onChange={(e) => onChange(e.target.value)}
          style={{ 
            width: '100%', 
            background: 'rgba(255,255,255,0.05)', 
            border: '1px solid var(--border)', 
            color: 'white', 
            padding: '12px', 
            borderRadius: '12px',
            outline: 'none'
          }}
        >
          {options.map(opt => <option key={opt} value={opt}>{opt}</option>)}
        </select>
      ) : (
        <input 
          type="text" 
          value={value} 
          onChange={(e) => onChange(e.target.value)}
          style={{ 
            width: '100%', 
            background: 'rgba(255,255,255,0.05)', 
            border: '1px solid var(--border)', 
            color: 'white', 
            padding: '12px', 
            borderRadius: '12px',
            outline: 'none'
          }} 
        />
      )}
    </div>
  )
}

function SidebarLink({ icon, label, active, onClick }) {
  return (
    <div 
      onClick={onClick}
      style={{ 
        display: 'flex', 
        alignItems: 'center', 
        gap: '12px', 
        padding: '12px 16px', 
        borderRadius: '12px',
        cursor: 'pointer',
        marginBottom: '4px',
        backgroundColor: active ? 'rgba(255, 255, 255, 0.05)' : 'transparent',
        color: active ? 'var(--primary)' : 'var(--text-muted)',
        transition: 'all 0.2s'
      }}
    >
      {icon}
      <span style={{ fontWeight: active ? '600' : '400' }}>{label}</span>
      {active && <ChevronRight size={16} style={{ marginLeft: 'auto' }} />}
    </div>
  )
}

function StatCard({ icon, label, value, trend }) {
  return (
    <div className="glass-card" style={{ padding: '24px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '16px' }}>
        <div style={{ 
          width: '44px', 
          height: '44px', 
          borderRadius: '12px', 
          backgroundColor: 'rgba(255, 255, 255, 0.05)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center'
        }}>
          {icon}
        </div>
        <span style={{ 
          color: trend.startsWith('+') ? '#22c55e' : '#ef4444', 
          fontSize: '12px', 
          fontWeight: '700' 
        }}>{trend}</span>
      </div>
      <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginBottom: '4px' }}>{label}</p>
      <h4 style={{ fontSize: '24px', fontWeight: '700' }}>{value}</h4>
    </div>
  )
}

function UserRow({ name, mobile, email, service, amount, date, status }) {
  const statusColors = {
    Approved: { bg: 'rgba(34, 197, 94, 0.1)', text: '#22c55e' },
    Pending: { bg: 'rgba(245, 158, 11, 0.1)', text: '#f59e0b' },
    Rejected: { bg: 'rgba(239, 68, 68, 0.1)', text: '#ef4444' }
  }

  return (
    <tr style={{ borderBottom: '1px solid var(--border)' }}>
      <td style={{ padding: '16px' }}>
        <div>
          <p style={{ fontWeight: '600', fontSize: '14px' }}>{name}</p>
          <p style={{ fontSize: '12px', color: 'var(--primary)', fontWeight: '500' }}>{mobile}</p>
        </div>
      </td>
      <td style={{ padding: '16px', fontSize: '14px' }}>{service}</td>
      <td style={{ padding: '16px', fontSize: '14px', fontWeight: '600' }}>{amount}</td>
      <td style={{ padding: '16px' }}>
        <span style={{ 
          padding: '4px 12px', 
          borderRadius: '20px', 
          fontSize: '11px', 
          fontWeight: '700',
          backgroundColor: statusColors[status]?.bg || 'rgba(255,255,255,0.05)',
          color: statusColors[status]?.text || 'white'
        }}>
          {status.toUpperCase()}
        </span>
      </td>
      <td style={{ padding: '16px', textAlign: 'right' }}>
        <button style={{ background: 'none', border: 'none', color: 'var(--text-muted)', cursor: 'pointer' }}>
          <MoreVertical size={18} />
        </button>
      </td>
    </tr>
  )
}

function UserManageRow({ user, onEdit, onApprove, onDelete }) {
  const statusColors = {
    Approved: { bg: 'rgba(34, 197, 94, 0.1)', text: '#22c55e' },
    Pending: { bg: 'rgba(245, 158, 11, 0.1)', text: '#f59e0b' },
    Rejected: { bg: 'rgba(239, 68, 68, 0.1)', text: '#ef4444' },
    Suspended: { bg: 'rgba(239, 68, 68, 0.1)', text: '#ef4444' }
  }

  return (
    <tr style={{ borderBottom: '1px solid var(--border)' }}>
      <td style={{ padding: '16px' }}>
        <div>
          <p style={{ fontWeight: '600', fontSize: '14px' }}>{user.name}</p>
          <p style={{ fontSize: '12px', color: 'var(--primary)', fontWeight: '500' }}>{user.mobile}</p>
        </div>
      </td>
      <td style={{ padding: '16px', fontSize: '14px' }}>
        <div>
          <p style={{ fontWeight: '500' }}>{user.service}</p>
          <p style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{user.amount}</p>
        </div>
      </td>
      <td style={{ padding: '16px', fontSize: '14px', color: 'var(--text-muted)' }}>{user.location}</td>
      <td style={{ padding: '16px' }}>
        <span style={{ 
          padding: '4px 12px', 
          borderRadius: '20px', 
          fontSize: '11px', 
          fontWeight: '700',
          backgroundColor: statusColors[user.status]?.bg || 'rgba(255,255,255,0.05)',
          color: statusColors[user.status]?.text || 'white'
        }}>
          {user.status.toUpperCase()}
        </span>
      </td>
      <td style={{ padding: '16px' }}>
        <div style={{ display: 'flex', gap: '8px' }}>
          <button 
            onClick={() => onEdit(user)}
            style={{ background: 'rgba(255,255,255,0.05)', border: 'none', color: 'white', padding: '6px 10px', borderRadius: '8px', fontSize: '12px', cursor: 'pointer' }}
          >
            Edit
          </button>
          {user.status === 'Pending' && (
            <button 
              onClick={() => onApprove(user.id)}
              style={{ background: 'rgba(34, 197, 94, 0.1)', border: 'none', color: '#22c55e', padding: '6px 10px', borderRadius: '8px', fontSize: '12px', fontWeight: '600', cursor: 'pointer' }}
            >
              Approve
            </button>
          )}
          <button 
            onClick={() => onDelete(user.id, user.name, user.table_name)}
            style={{ background: 'rgba(239, 68, 68, 0.1)', border: 'none', color: '#ef4444', padding: '6px 10px', borderRadius: '8px', fontSize: '12px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}
          >
            <Trash2 size={14} />
            Delete
          </button>
        </div>
      </td>
    </tr>
  )
}

function ServiceCard({ title, activeApps, status }) {
  return (
    <div className="glass-card" style={{ padding: '32px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '24px' }}>
        <h4 style={{ fontSize: '18px', fontWeight: '700' }}>{title}</h4>
        <span style={{ 
          fontSize: '11px', 
          fontWeight: '700', 
          color: status === 'Active' ? '#22c55e' : '#f59e0b',
          backgroundColor: status === 'Active' ? 'rgba(34, 197, 94, 0.1)' : 'rgba(245, 158, 11, 0.1)',
          padding: '4px 8px',
          borderRadius: '8px'
        }}>{status.toUpperCase()}</span>
      </div>
      <p style={{ color: 'var(--text-muted)', fontSize: '14px', marginBottom: '4px' }}>Active Applications</p>
      <p style={{ fontSize: '24px', fontWeight: '700', marginBottom: '24px' }}>{activeApps}</p>
      <button className="glass-card" style={{ width: '100%', padding: '10px', borderRadius: '12px', fontSize: '14px', fontWeight: '600' }}>Manage Service</button>
    </div>
  )
}

function SettingItem({ label, type, checked }) {
  return (
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
      <p style={{ fontSize: '15px' }}>{label}</p>
      {type === 'toggle' && (
        <div style={{ 
          width: '44px', 
          height: '24px', 
          borderRadius: '12px', 
          backgroundColor: checked ? 'var(--primary)' : 'rgba(255,255,255,0.1)',
          position: 'relative',
          cursor: 'pointer'
        }}>
          <div style={{ 
            width: '18px', 
            height: '18px', 
            borderRadius: '50%', 
            backgroundColor: 'white', 
            position: 'absolute', 
            top: '3px', 
            left: checked ? '23px' : '3px',
            transition: 'all 0.2s'
          }}></div>
        </div>
      )}
    </div>
  )
}

export default App
