[
  ['Home Phone', 'string'],
  ['Work Phone', 'string'],
  ['Cell Phone', 'string'],
  ['Physical Address', 'text'],
  ['Postal Address', 'text']
].each do |name,field_type|
  DetailType.seed(:name, true) do |sd|
    sd.name = name
    sd.field_type = field_type
  end
end
