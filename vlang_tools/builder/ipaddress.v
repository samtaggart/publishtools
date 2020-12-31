module builder

enum PortType {
	tcp
	udp
}

pub struct Port {
	number int
	cat    PortType
}

pub struct IPAddress {
	addr string
	port Port
	cat  IpAddressType
}

pub enum IpAddressType {
	ipv4
	ipv6
}

// get the right name depending the platform type
pub fn (mut ipaddr IPAddress) ping(executor Executor) {
	// TODO: implement using ping over executor, support 4 & 6
}

// check if ipaddress is well formed
fn (mut ipaddr IPAddress) check() ? {
	// TODO: check if well formed
}

fn (mut ipaddr IPAddress) address() string {
	return '$ipaddr.addr:$ipaddr.port'
}