#vim:ft=rspec:

%define __spec_prep_post true
%define __spec_prep_pre true
%define __spec_build_post true
%define __spec_build_pre true
%define __spec_install_post true
%define __spec_install_pre true
%define __spec_clean_post true
%define __spec_clean_pre true
%define _binary_filedigest_algorithm 1
%define _binary_payload w9.gzdio

%define __bundle_bin %(which bundle)
%define __useradd_bin %(which useradd)
%define __app_name clearsale
%define __apps_path /eden/app/

Name:        clearsale
Version:     %{version}
Release:     %{?dist}
Summary:     no description given
Group:       Application/Internet
BuildRoot:   %{buildroot}
License:     2012 Edenbrasil
BuildArch:   noarch
Vendor:      dev@baby.com.br
URL:         http://www.baby.com.br
AutoReqProv: no

%description
no description given

%prep
  %{__mkdir} -p %{_builddir}/%{version}/%{__apps_path}/config
  %{__mkdir} -p %{_builddir}/%{version}/%{__apps_path}/lib
  %{__mkdir} -p %{_builddir}/%{version}/%{__apps_path}/scripts
  %{__mkdir} -p %{_builddir}/%{version}/%{__apps_path}/%{__app_name}

%build
  %{__cp} -r %{__project_dir}/config/*        %{_builddir}/%{version}/%{__apps_path}/config/.
  %{__cp} -r %{__project_dir}/scripts/*       %{_builddir}/%{version}/%{__apps_path}/scripts/.
  %{__cp} -r %{__project_dir}/lib/*           %{_builddir}/%{version}/%{__apps_path}/lib/.
  %{__cp} -r %{__project_dir}/%{__app_name}/* %{_builddir}/%{version}/%{__apps_path}/%{__app_name}/.

%clean
  %{__rm} -rf %{_builddir}/%{version}/%{__apps_path}
  %{__rm} -rf %{buildroot}

%install
  %{__mkdir} -p %{buildroot}%{__apps_path}/scripts
  %{__mkdir} -p %{buildroot}%{__apps_path}/lib
  %{__mkdir} -p %{buildroot}%{__apps_path}/%{__app_name}
  %{__mkdir} -p %{buildroot}%{__apps_path}/%{__app_name}/.bundle
  %{__mkdir} -p %{buildroot}%{__apps_path}/%{__app_name}/tmp/pids
  %{__mkdir} -p %{buildroot}%{__apps_path}/%{__app_name}/tmp/sockets

  %{__cp} -r %{_builddir}/%{version}/%{__apps_path}/scripts/*               %{buildroot}%{__apps_path}/scripts/.
  %{__cp} -r %{_builddir}/%{version}/%{__apps_path}/lib/*                   %{buildroot}%{__apps_path}/lib/.
  %{__cp} -r %{_builddir}/%{version}/%{__apps_path}/%{__app_name}/*         %{buildroot}%{__apps_path}/%{__app_name}/.
  %{__cp} -r %{_builddir}/%{version}/%{__apps_path}/%{__app_name}/.bundle/* %{buildroot}%{__apps_path}/%{__app_name}/.bundle/.

%files
%defattr(-,baby,baby,-)
%{__apps_path}/scripts/.
%{__apps_path}/lib/.
%{__apps_path}/%{__app_name}/.
%{__apps_path}/%{__app_name}/.bundle/.
%exclude %{__apps_path}/%{__app_name}/log
%exclude %{__apps_path}/%{__app_name}/spec

%pre
  if [[ $(%{__id} baby 2>/dev/null) ]]; then
    echo "baby user already exists";
  else
    %{__groupadd_bin} -g 1000 app
    %{__useradd_bin} -u 2002 -g app -m -c "Baby" -s /bin/bash baby
  fi

%post
  if [[ ! -L %{__apps_path}%{__app_name}/scripts/fake-clearsale-init.sh ]]; then
    ln -fs %{__apps_path}%{__app_name}/scripts/fake-clearsale-init.sh %{_sysconfdir}/init.d/unicorn_%{__app_name}
  fi
  if [[ ! -L %{__apps_path}%{__app_name}/log ]]; then
    ln -s /eden/log %{__apps_path}%{__app_name}/log
  fi

%changelog

