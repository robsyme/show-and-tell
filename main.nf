#!/usr/bin/env nextflow
echo true

cheers = Channel.from 'Bonjour', 'Ciao', 'Hello', 'Hola', 'Γεια σου'
enthusiasmLevels = [1, 5, 10, 20]

process sayHello {
  input: 
  val x from cheers

  output:
  file 'output.txt' into unexcited

  """
  echo '$x world!' > output.txt
  """
}

unexcited
.spread(enthusiasmLevels)
.set { greetingWithLevel }

process exclaim {
  input:
  set file('input.txt'), val(enthusiasm) from greetingWithLevel

  output:
  set val(enthusiasm), file('excited.txt') into excited

  """
#!/usr/bin/env ruby
File.open('excited.txt', 'w') do |out|
  out.print(File.read('input.txt').chomp)
  out.puts '!' * $enthusiasm
end
  """
}

excited
.groupTuple()
.set { groupedGreetings }

process groupGreetings {
  publishDir '/tmp/output', mode: 'copy'

  input:
  set enthusiasm, 'input.*.txt' from groupedGreetings

  output:
  file "finalGroup-${enthusiasm}.txt" into finalGreetings

  """
cat input.*.txt > finalGroup-${enthusiasm}.txt
  """  
}

finalGreetings.println()
