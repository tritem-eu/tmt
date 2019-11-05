class Tmt::MachinePresenter < ApplicationPresenter
  presents :machine

  def hostname
    h content_or_none(machine.hostname)
  end

  def ip_address
    h content_or_none(machine.ip_address)
  end

  def mac_address
    h content_or_none(machine.mac_address)
  end

  def fully_qualified_domain_name
    h content_or_none(machine.fully_qualified_domain_name)
  end

end
