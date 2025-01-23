<%
from jsonxs import jsonxs
%>
<%def name="col_fqdn(host)"><%
  return jsonxs(host, 'ansible_facts.ansible_fqdn', default='')
%></%def>
<%def name="col_id(host)"><%
  return  int(jsonxs(host, 'ansible_facts.ansible_machine_id', default='-1'),base=16)
%></%def>
<%def name="col_main_ip(host)"><%
  default_ipv4 = ''
  if jsonxs(host, 'ansible_facts.ansible_os_family', default='') == 'Windows':
    ipv4_addresses = [ip for ip in jsonxs(host, 'ansible_facts.ansible_ip_addresses', default=[]) if ':' not in ip]
    if ipv4_addresses:
      default_ipv4 = ipv4_addresses[0]
  else:
    default_ipv4_fact = jsonxs(host, 'ansible_facts.ansible_default_ipv4.address', default='')
    if default_ipv4_fact:
      default_ipv4 = default_ipv4_fact[0]
    else: 
      all_ipv4_addresses = [ip4 for ip4 in jsonxs(host, 'ansible_facts.ansible_all_ipv4_addresses', default=[]) if ':' not in ip4] 
      if all_ipv4_addresses:
        default_ipv4 = all_ipv4_addresses[0]
  
  return default_ipv4.strip()
%></%def>
<%def name="col_os_name(host)"><%
  return jsonxs(host, 'ansible_facts.ansible_distribution', default='')
%></%def>
<%def name="col_os_version(host)"><%
  if jsonxs(host, 'ansible_facts.ansible_distribution', default='') in ["OpenBSD"]:
    return jsonxs(host, 'ansible_facts.ansible_distribution_release', default='')
  else:
    return jsonxs(host, 'ansible_facts.ansible_distribution_version', default='')
  endif
%></%def>
<%def name="col_system_type(host)"><%
  return jsonxs(host, 'ansible_facts.ansible_system', default='')
%></%def>
<%def name="col_kernel(host)"><%
  return jsonxs(host, 'ansible_facts.ansible_kernel', default='')
%></%def>
<%def name="col_arch_hardware(host)"><%
  return jsonxs(host, 'ansible_facts.ansible_architecture', default='')
%></%def>
<%def name="col_arch_userspace(host)"><%
  return jsonxs(host, 'ansible_facts.ansible_userspace_architecture', default='')
%></%def>
<%def name="col_virt_type(host)"><%
  return jsonxs(host, 'ansible_facts.ansible_virtualization_type', default='?')
%></%def>
<%def name="col_virt_role(host)"><%
  return jsonxs(host, 'ansible_facts.ansible_virtualization_role', default='?')
%></%def>
<%def name="col_cpu_type(host)"><%
  cpu_type = jsonxs(host, 'ansible_facts.ansible_processor', default=0)[0:60]
  if isinstance(cpu_type, list) and len(cpu_type) > 0:
    return cpu_type[-1]
  else:
    return ''
%></%def>
<%def name="col_vcpus(host)"><%
  if jsonxs(host, 'ansible_facts.ansible_distribution', default='') in ["OpenBSD"]:
    return jsonxs(host, 'ansible_facts.ansible_processor_count', default=0)
  else:
    return jsonxs(host, 'ansible_facts.ansible_processor_vcpus', default=jsonxs(host, 'ansible_facts.ansible_processor_cores', default=0))
  endif
%></%def>
<%def name="col_ram(host)"><%
  return '%0.1f' % ((int(jsonxs(host, 'ansible_facts.ansible_memtotal_mb', default=0)) / 1024.0))
%></%def>
<%def name="col_disk_total(host)"><%
  for i in jsonxs(host, 'ansible_facts.ansible_mounts', default=[]):
    if i["mount"] == '/':
      return round(i.get('size_total', 0) / 1073741824.0, 1)
    endif
  endfor
  return 0
%></%def>
<%def name="col_disk_free(host)"><%
  for i in jsonxs(host, 'ansible_facts.ansible_mounts', default=[]):
    if i["mount"] == '/':
      try:
        return round(i["size_available"] / 1073741824.0, 1)
      except:
        return 0
      endtry
    endif
  endfor
  return 0
%></%def>
    # This file should ensure the existence of records required to run the application in every environment (production,
    # development, test). The code here should be idempotent so that it can be executed at any point in every environment.
    # The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
    #
    # Example:
    #
    #   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
    #     MovieGenre.find_or_create_by!(name: genre_name)
    #   end
    #   

    # for svr model :
% for hostname, host in sorted(hosts.items()):
Svr.create!(
    id: ${col_id(host)},
    name: "${jsonxs(host, 'name', default='Unknown')}",
    fqdn: "${col_fqdn(host)}",
    main_ip: "${col_main_ip(host)}",
    os_name:  "${col_os_name(host)}",
    os_version: "${col_os_version(host)}",
    system_type: "${col_system_type(host)}",
    kernel: "${col_kernel(host)}",
    arch_hardware: "${col_arch_hardware(host)}",
    arch_userspace: "${col_arch_userspace(host)}",
    virt_type: "${col_virt_type(host)}",
    virt_role: "${col_virt_role(host)}",
    cpu_type: "${col_cpu_type(host)}",
    vcpus: ${col_vcpus(host)},
    ram: ${col_ram(host)},
    disk_total: ${col_disk_total(host)},
    disk_free: ${col_disk_free(host)}, 
    todo: "nothing",
    nagios: "",
    nagios_id: "${jsonxs(host, 'name', default="Unknown")}",
    pending: false,
    pkg: false 
 )
%endfor
