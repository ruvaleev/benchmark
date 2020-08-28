# frozen_string_literal: true

require 'benchmark/ips'

# To evaluate perfomance in development mode:
# change ONLY `measure` method
# to run evaluation
# 1) require this file `require './profilers/benchmark_evaluation'`
# 2) run `BenchmarkEvaluation.new.run`
# save results for colleagues
# and comment them (inside of your 'measure' implementation, to let anyone check correctness)

class BenchmarkEvaluation
  def run
    Rails.logger.level = 1

    Benchmark.ips do |x|
      x.time = 5
      x.warmup = 2

      measure(x)

      x.compare!
    end

    Rails.logger.level = 0
  end

  private

  def measure(x) # rubocop:disable Naming/MethodParameterName
    x.report('none?') do
      User.none?
    end
    x.report('blank?') do
      User.blank?
    end
    x.report('exists?') do
      User.exists?
    end
    x.report('present?') do
      User.present?
    end

    # Warming up --------------------------------------
    #            none?   263.000  i/100ms
    #           blank?    41.784k i/100ms
    #          exists?    99.000  i/100ms
    #         present?    73.422k i/100ms
    # Calculating -------------------------------------
    #               none?      2.507k (± 8.5%) i/s -     12.624k in   5.073990s
    #               blank?    885.237k (± 6.1%) i/s -      4.429M in   5.023068s
    #             exists?      2.596k (±12.0%) i/s -     12.870k in   5.035559s
    #             present?    866.059k (± 4.0%) i/s -      4.332M in   5.010224s

    # Comparison:
    #               blank?:   885237.2 i/s
    #             present?:   866059.3 i/s - same-ish: difference falls within error
    #             exists?:     2595.8 i/s - 341.03x  (± 0.00) slower
    #               none?:     2507.4 i/s - 353.05x  (± 0.00) slower
  end
end
