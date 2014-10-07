[
  ['Coat Check',        'Responsible for coats and bags'],
  ['Merch / Programme', 'To sell merchandising, programmes etc'],
  ['Receptionist',      'Front of House reception at all venues'],
  ['Security',          'Backstage, Plimmers Ark and Dockway'],
  ['Supervisor',        'Supervise front of house team']
].each do |role_name, role_description|
  Role.seed(:name) do |r|
    r.name = role_name
    r.description = role_description
  end
end
